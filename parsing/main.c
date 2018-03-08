#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define BUF_SIZE 4 * 1024 * 1024
#define PACKET_SIZE 188

#define BIG_BUF_SIZE 100*1024*1024

#define DVALID 0x01
#define CLOCK  0x02
#define PSYNC  0x04


typedef enum _steps
{
    STEP_LOOK_START,
    STEP_IN_PACKET,
} steps_t;

int main(int argc, char *argv[])
{
    if (argc < 3) {
        printf("%s: missing argument (infile, outfile)\n", argv[0]);
        return 1;
    }

    int input_fd, output_fd;    /* Input and output file descriptors */
    ssize_t ret_in, ret_out;    /* Number of bytes returned by read and write */
    char buffer[BUF_SIZE];      /* Character buffer */
    char packet[PACKET_SIZE];   /* Packet to write */

    char* big_buffer; int big_buffer_idx = 0;
    big_buffer = malloc(BIG_BUF_SIZE);
    if (!big_buffer)
    {
        printf ("malloc error\n");
        return 2;
    }

    /* Create input file descriptor */
    input_fd = open (argv[1], O_RDONLY);
    if (input_fd == -1) {
        printf ("open error\n");
        return 2;
    }
 
    /* Create output file descriptor */
    output_fd = open(argv[2], O_WRONLY | O_CREAT, 0644);
    if(output_fd == -1){
        printf("open 2 error \n");
        return 3;
    }
 
    /* Copy process */
    steps_t step = STEP_LOOK_START;
    int packet_count, offset;
    while((ret_in = read (input_fd, &buffer, BUF_SIZE)) > 0)
    {
        //printf("length %d\n", ret_in);

        for(offset = 0; offset < ret_in; offset += 2)
        {
            //printf("step %d: %02x %02x\n", step, buffer[offset+0], buffer[offset+1]);
            switch (step)
            {
                case (STEP_LOOK_START):
                    if (buffer[offset+0] & PSYNC)
                    {
                        //printf("start: %x %x\n", buffer[offset+0], buffer[offset+1]);
                        packet_count = 0;
                        packet[packet_count] = buffer[offset+1];
                        packet_count++;
                        step = STEP_IN_PACKET;
                    }
                    else
                    {
                        //printf("NO start: %x %x\n", buffer[offset+0], buffer[offset+1]);
                    }
                    break;
                case (STEP_IN_PACKET):
                    packet[packet_count] = buffer[offset+1];
                    packet_count++;
                    
                    if (packet_count == PACKET_SIZE)
                    {
                        // Either write it directly or fill a big buffer
                        
                        //printf("packet found\n");
                        //ret_out = write (output_fd, &packet, (ssize_t) packet_count);
                        //if(ret_out != packet_count
                        //{
                        //    printf("write error: %d != %d\n", ret_out, packet_count);
                        //}
                        
                        if (big_buffer_idx + packet_count < BIG_BUF_SIZE)
                        {
                            memcpy(big_buffer+big_buffer_idx, packet, packet_count);
                            big_buffer_idx += packet_count;
                        }
                        if (big_buffer_idx + packet_count > BIG_BUF_SIZE)
                        {
                            printf("big buffer full\n");
                            ret_out = write(output_fd, big_buffer, (ssize_t) big_buffer_idx);
                            if(ret_out != big_buffer_idx)
                            {
                                printf("write error: %d != %d, errno %d\n", ret_out, big_buffer_idx, errno);
                            }
                            printf("big buffer written\n");
                            fsync(output_fd);
                            printf("big buffer synced\n");
                            big_buffer_idx = 0;
                        }
                        step = STEP_LOOK_START;
                    }
                    break;
                default:
                break;
            }
        }
        //fsync(output_fd);
    }
 
    /* Close file descriptors */
    close (input_fd);
    close (output_fd);
 
    return 0;
}

