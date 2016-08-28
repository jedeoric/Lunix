/* tap2dsk : converts an Oric tape image to a sedoric/stratsed dsk image */
/* (c) F.Frances 2004 */

/* Limitations :
 *   - only 1 bitmap sector, thus limits the capacity to ~2048 sectors
 *   - only 1 side with 80 tracks max.
 */

#include <stdio.h>
#define NBTRACKS 21
#define NBSECT 17

typedef unsigned char byte;
typedef byte sector[256];

struct {
	char signature[8];
	int sides;
	int tracks;
	int sect;
	char pad[256-20];
} imageheader = { "ORICDISK", 1, NBTRACKS, NBSECT };

sector disk[80][NBSECT];
sector directory,descriptor;
sector system_sect={	// some system parameters
	0,0,0,0,	// drive table, unread on slave disk
	0,			// keyboard type, unread on slave disk
	0,0,0,0,	// RENUM parameters, unread on slave disk
	'T','A','P','2','D','S','K',' ','S','A','M','P','L','E',' ','D','I','S','C',' ',' '
};
sector bitmap={
	0xFF,		// signature
	0,
	0,0,		// number of free sectors
	0,0,		// number of files
	NBTRACKS,	// number of tracks/side
	NBSECT,		// number of sectors/track
	1,			// number of directory sectors
	NBTRACKS,	// number of tracks + 128 if double sided
	1			// master/slave/gameinit indicator
};
int track,sect=1;
int dir_offset=0x10;
int used_sectors;

void allocate_sector(int track, int sect, byte *contents)
{
	int linear_sector=track*NBSECT+sect-1;
	bitmap[0x10+linear_sector/8] &= ~(1<<linear_sector%8);
	memcpy(disk[track][sect-1],contents,sizeof(sector));
	used_sectors++;
}

void find_free_sector(byte *contents)
{
	int linear_sector=0;
	while ((bitmap[0x10+linear_sector/8] & (1<<linear_sector%8)) == 0)
		linear_sector++;

	track=linear_sector/NBSECT;
	sect=linear_sector%NBSECT+1;
	if (track==80) {
		fprintf(stderr,"Not enough space on sample disc");
		exit(1);
	}
	allocate_sector(track,sect,contents);
}

void update_sector(int track, int sect, byte *contents)
{
	memcpy(disk[track][sect-1],contents,sizeof(sector));
}

void convert_basename(char *dest, char *name)
{
	static int filenumber=0;
	int dest_offset=0, src_offset=0;
	while (dest_offset<9 && src_offset<17 && name[src_offset]) {
		if (name[src_offset]>='a' && name[src_offset]<='z')
			name[src_offset]-=0x20;
		if (name[src_offset]>='0' && name[src_offset]<='9' 
			|| name[src_offset]>='A' && name[src_offset]<='Z')
			dest[dest_offset++]=name[src_offset];
		src_offset++;
	}
	if (dest_offset) {
		while (dest_offset<9)
			dest[dest_offset++]=' ';
	} else
		sprintf(dest,"NONAME%03d",filenumber++);
}

void store_file(byte *buf, char *name, byte *header)
{
	int start=(header[6]<<8)+header[7];
	int end=(header[4]<<8)+header[5];
	int exec=header[3];
	int block=header[2];
	int sectors=(end-start)/sizeof(sector)+1;
	int desc_sect,desc_track;
	int desc_off=0x0C;
	int offset;

	memset(descriptor,0,sizeof(sector));
	find_free_sector(descriptor);
	desc_track=track; desc_sect=sect;
	descriptor[2]=0xFF;
	descriptor[3]=(block?0x40:0x80)+(exec?1:0);
	descriptor[4]=header[7];
	descriptor[5]=header[6];
	descriptor[6]=header[5];
	descriptor[7]=header[4];
	if (exec) {
		descriptor[8]=descriptor[4];
		descriptor[9]=descriptor[5];
	} else {
		descriptor[8]=descriptor[9]=0;
	}
	descriptor[10]=sectors&0xFF;
	descriptor[11]=sectors>>8;

	convert_basename(directory+dir_offset,name);
	if (exec)
		sprintf(directory+dir_offset+9,"COM");
	else sprintf(directory+dir_offset+9,"%s",block?"BIN":"BAS");
	directory[dir_offset+12]=desc_track;
	directory[dir_offset+13]=desc_sect;
	directory[dir_offset+14]=sectors+1+(sectors>=(256-12)/2?1:0); // Sedoric bug work-around : allocate a second descriptor when exactly 122 sectors of data
	directory[dir_offset+15]=0x40; // UNPROT

	while (sectors--) {
		find_free_sector(buf);
		buf+=sizeof(sector);
		descriptor[desc_off++]=track;
		descriptor[desc_off++]=sect;
		if (desc_off==0x100) {			// Sedoric bug work-around : allocate a second descriptor when the first is full, even if not needed
			find_free_sector(descriptor);
			descriptor[0]=track;
			descriptor[1]=sect;
			update_sector(desc_track,desc_sect,descriptor);
			memset(descriptor,0,sizeof(sector));
			desc_track=track;
			desc_sect=sect;
			desc_off=2;
		}
	}
	update_sector(desc_track,desc_sect,descriptor);
}

int main(int argc, char *argv[])
{
	byte header[9];
	char name[17];
	byte file_buffer[48*1024];
	FILE *tape, *dsk;
	int dir_track=20, dir_sect=4;
	int tracks=21; // minimum track number
	int total_sectors,free_sectors;

	if (argc!=3) {
		fprintf(stderr,"Usage: tap2dsk <tape_image> <old_disk_image>\n");
		exit(1);
	}
	tape=fopen(argv[1],"rb");
	if (tape==NULL) {
		fprintf(stderr,"Cannot read tape image %s\n",argv[1]);
		exit(1);
	}
	dsk=fopen(argv[2],"wb");
	if (dsk==NULL) {
		fprintf(stderr,"Cannot open %s for writing\n",argv[2]);
		exit(1);
	}

	memset(bitmap+0x10,0xFF,sizeof(sector)-0x10);
	allocate_sector(20,1,system_sect);
	allocate_sector(20,2,bitmap);
	allocate_sector(20,4,directory);
	while (fgetc(tape)!=EOF) {
		int start,end,i;
		while (fgetc(tape)!=0x24)
			;
		for (i=0;i<9;i++) header[i]=fgetc(tape);
		for (i=0;i<17;i++) {
			name[i]=fgetc(tape);
			if (name[i]==0) break;
		}
		start=(header[6]<<8)+header[7];
		end=(header[4]<<8)+header[5];
		for (i=0; i<end+1-start; i++)
			file_buffer[i]=fgetc(tape);
		printf("Storing %s\n",name);
		store_file(file_buffer,name,header);
		bitmap[4]++; // number of files
		dir_offset+=16;
		if (dir_offset==0x100) {
			find_free_sector(directory);
			directory[0]=track;
			directory[1]=sect;
			update_sector(dir_track,dir_sect,directory);
			memset(directory,0,sizeof(sector));
			dir_track=track;
			dir_sect=sect;
			dir_offset=0x10;
			update_sector(dir_track,dir_sect,directory);
		}
	}
	directory[2]=dir_offset;
	update_sector(dir_track,dir_sect,directory);

	if (track>=tracks) tracks=track+1;
	total_sectors=tracks*NBSECT;
	free_sectors=total_sectors-used_sectors;
	bitmap[2]=free_sectors & 0xFF;
	bitmap[3]=free_sectors >> 8;
	bitmap[6]=tracks;
	bitmap[9]=tracks;
	update_sector(20,2,bitmap);

	imageheader.tracks=tracks;
	fwrite(&imageheader,sizeof(imageheader),1,dsk);
	for (track=0;track<tracks;track++)
		for (sect=1;sect<=NBSECT;sect++)
			fwrite(disk[track][sect-1],sizeof(sector),1,dsk);
	return 0;
}
