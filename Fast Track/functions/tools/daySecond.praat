
## writes value to daySecond global variable

procedure daySecond

  .time$ = date$()
  .time$ = mid$ (.time$, 12,8)

  .hour$ = left$ (.time$,2)
  .hour = number (.hour$)
  .minute$ = mid$ (.time$,4, 2)
  .minute = number (.minute$)
  .second$ = right$ (.time$,2)
  .second = number (.second$)
  daySecond = (.hour*60*60)+(.minute*60)+.second

endproc
