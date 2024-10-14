#include <stdbool.h>

bool canReachOnTime(int dist[], int n, int speed, double hour) {
    double totalTime = 0.0;
    for (int i = 0; i < n; i++) {
        double time = (double)dist[i] / speed;
        if (i < n - 1) {
            // Using integer arithmetic to compute the ceiling
            totalTime += (dist[i] + speed - 1) / speed;
        } else {
            totalTime += time;
        }
    }
    return totalTime <= hour;
}

int minSpeedOnTime(int* dist, int distSize, double hour) {
    int left = 1, right = 10000000;
    int result = -1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        if (canReachOnTime(dist, distSize, mid, hour)) {
            result = mid;
            right = mid - 1; // Try to find a smaller speed
        } else {
            left = mid + 1;  // Increase speed
        }
    }
    
    return result;
}