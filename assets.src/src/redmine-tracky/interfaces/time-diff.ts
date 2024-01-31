export interface TimeDiff {
    hours: number;
    minutes: number;
    seconds: number;
}

export function timeDiffToString(timeDiff: TimeDiff) {
    let res = '';

    const time = [timeDiff.hours, timeDiff.minutes, Math.round(timeDiff.seconds)]
        .map((value) => value.toString().replace('-', '').padStart(2, '0'))

    if (timeDiff.minutes < 0 || timeDiff.seconds < 0) {
        res = '-';
    }
    if (Number(time[0]) > 0) {
        res += `${time[0]}:`;
    }

    return `${res}${time[1]}:${time[2]}`;
}
