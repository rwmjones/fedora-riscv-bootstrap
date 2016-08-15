#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <linux/reboot.h>

main ()
{
  sync ();
  reboot (LINUX_REBOOT_CMD_POWER_OFF);
  perror ("poweroff");
  exit (EXIT_FAILURE);
}
