: Date#-ap { d m y -- }
  y #N [CHAR] / HOLD m DateM>S HOLDS [CHAR] / HOLD d #N
;
: DateTime#Z-ap { s m h d m1 y -- }
  TZ @ 0= IF GET-TIME-ZONE THEN
  TZ @ 60 / NEGATE DUP >R ABS 100 * 0 # # # # 2DROP
  R> 0 > IF [CHAR] + ELSE [CHAR] - THEN HOLD BL HOLD
  h m s Time# [CHAR] : HOLD d m1 y Date#-ap
;
: CurrentDateTime#Z-ap
  TIME&DATE DateTime#Z-ap
;
: DATE-ap \ для использования в " ...{DATE-ap}..."
  <<# CurrentDateTime#Z-ap #>
;
