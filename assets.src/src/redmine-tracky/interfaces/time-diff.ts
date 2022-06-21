export interface TimeDiff {
    hours: number;
    minutes: number;
    seconds: number;
}


export function timeDiffToString(timeDiff: TimeDiff): string {
    const seconds: string = padNumber(Math.round(timeDiff.seconds).toString(), 2);
    const minutes: string = padNumber(timeDiff.minutes.toString(), 2);

    if (timeDiff.hours > 0) {
        return `${timeDiff.hours}:${minutes}:${seconds}`;
    } else {

        return `${minutes}:${seconds}`;
    }
}

function padNumber(n: string, width: number) {
    n = n + '';
    return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
}
