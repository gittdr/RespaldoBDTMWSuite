SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Version : 1.0
SP que agrega las expiraciones de tractores por dia sobre un calendario
recibi de parametro la flota y los meses atras o adelante, mes atras con signo de menos
mes actual con 0

exec  sp_exptrcmonth  'ABIERTO1', 0


*/


CREATE proc [dbo].[sp_exptrcmonth]  @flota varchar(20), @month int

as

SET LANGUAGE Spanish; 

select '' as Tractor,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)),'dd-MM')as dia1,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 1)),'dd-MM')as dia2,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 2)),'dd-MM')as dia3,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 3)),'dd-MM')as dia4,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 4)),'dd-MM')as dia5,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 5)),'dd-MM')as dia6,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 6)),'dd-MM')as dia7,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 7)),'dd-MM')as dia8,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 8)),'dd-MM')as dia9,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 9)),'dd-MM')as dia10,

 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 10)),'dd-MM')as dia11,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 11)),'dd-MM')as dia12,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 12)),'dd-MM')as dia13,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 13)),'dd-MM')as dia14,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 14)),'dd-MM')as dia15,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 15)),'dd-MM')as dia16,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 16)),'dd-MM')as dia17,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 17)),'dd-MM')as dia18,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 18)),'dd-MM')as dia19,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 19)),'dd-MM')as dia20,

 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 20)),'dd-MM')as dia21,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 21)),'dd-MM')as dia22,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 22)),'dd-MM')as dia23,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 23)),'dd-MM')as dia24,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 24)),'dd-MM')as dia25,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 25)),'dd-MM')as dia26,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 26)),'dd-MM')as dia27,
 format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 27)),'dd-MM')as dia28,
 case when   dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 27))   =  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 28)) then '' else  format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 28)),'dd-MM') end as dia29,
 case when   dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 28))   =  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 29)) then '' else  format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 29)),'dd-MM') end as dia30,
  case when  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 29))   =  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 30)) then '' else  format(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 30)),'dd-MM') end as dia31

union

select '' as Trc,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)))) as dia1,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 1)))) as dia2,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 2)))) as dia3,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 3)))) as dia4,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 4)))) as dia5,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 5)))) as dia6,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 6)))) as dia7,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 7)))) as dia8,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 8)))) as dia9,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 9)))) as dia10,

 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 10)))) as dia11,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 11)))) as dia12,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 12)))) as dia13,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 13)))) as dia14,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 14)))) as dia15,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 15)))) as dia16,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 16)))) as dia17,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 17)))) as dia18,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 18)))) as dia19,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 19)))) as dia20,
 
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 20)))) as dia21,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 21)))) as dia22,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 22)))) as dia23,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 23)))) as dia24,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 24)))) as dia25,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 25)))) as dia26,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 26)))) as dia27,
 datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 27)))) as dia28,


 case when   dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 27))   =  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 28)) then '' else  datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 28)))) end as dia29,
 case when   dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 28))   =  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 29)) then '' else  datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 29)))) end as dia30,
 case when  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 29))   =  dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 30)) then '' else  datename(dw,(dateadd(month,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 30)))) end as dia31

 union


select trc_number as Tractor,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia1,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 1)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia2,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 2)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia3,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 3)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia4,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 4)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia5,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 5)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia6,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 6)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia7,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 7)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia8,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 8)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia9,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 9)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia10,

	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 10)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia11,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 11)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia12,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 12)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia13,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 13)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia14,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 14)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia15,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 15)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia16,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 16)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia17,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 17)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia18,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 18)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia19,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 19)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia20,

	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 20)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia21,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 21)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia22,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 22)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia23,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 23)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia24,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 24)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia25,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 25)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia26,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 26)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia27,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 27)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia28,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 28)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia29,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 29)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia30,
	   isnull( STUFF(( select ',' + exp_code   from expiration where exp_completed = 'N' and exp_idtype = 'TRC'  and  dateadd(MONTH,@month,DATEADD(m, DATEDIFF(m, 0, GETDATE()), 30)) between exp_expirationdate and exp_lastdate and exp_id = trc_number  FOR XML PATH('')  ), 1, 1, ''),'') as dia31
    

from tractorprofile
where
trc_fleet =  (select abbr from labelfile where labeldefinition = 'fleet' and name in (@flota )) and 
trc_status <> 'OUT' and trc_number <> 'UNKNOWN'



GO
