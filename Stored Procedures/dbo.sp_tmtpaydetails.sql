SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
Autor: Emilio Olvera
Version : 1.3
Date: Jul 13 2020

exec sp_tmtpaydetails

*/


CREATE proc [dbo].[sp_tmtpaydetails]

as

declare @poinvoicid int, @order int, @ordernum varchar(20), @unit varchar(20), 
@billed float, @paid float, @modifiedby varchar(10), @drv varchar(20),
@msgtmt varchar(200), @callnum varchar(20), @leg varchar(20)


declare cursor_tmtpaydetails cursor

for

	select 
	  poinvoicid,
      orderid,
	  (select ordernum from [172.24.16.113].tmwams.dbo.orders where orders.orderid = poinvoic.orderid) as ordernum,
	  (select (select unitnumber from [172.24.16.113].tmwams.dbo.units where units.unitid = orders.unitid) from [172.24.16.113].tmwams.dbo.orders where orders.orderid = poinvoic.orderid) as unit,
      amtbilled, 
      amtpaid,
      modifiedby,
	  (select empid from [172.24.16.113].tmwams.dbo.employee where empdrvid = 
	  ( isnull(((select (select empdrvid from [172.24.16.113].tmwams.dbo.callmst ca where  ca.callid = cc.callid) from [172.24.16.113].tmwams.dbo.callorders cc where cc.orderid = poinvoic.orderid)), 

	  (  select max(empdrvid) from [172.24.16.113].tmwams.dbo.empunit where unitid = ( select unitid from [172.24.16.113].tmwams.dbo.orders where orders.orderid = poinvoic.orderid)) ))) as driver,

	  (select (select callnum from [172.24.16.113].tmwams.dbo.callmst ca where  ca.callid = cc.callid) from [172.24.16.113].tmwams.dbo.callorders cc where cc.orderid = poinvoic.orderid) as roadcall

	from [172.24.16.113].tmwams.dbo.poinvoic as poinvoic
	where rtrim(PAYMETHOD) = 'DRV ADVANCE'
	and  orderid  not in (select amsorderid from tmwams_auditpaydetail )

	/*audit table-----
	(select * from tmwams_auditpaydetail )


	select * from paydetail where lgh_number = 1095082
	delete paydetail where pyd_number = '5962925'
	update paydetail set pyd_description = ' RoadCall: 000000000074   Orden TMT: 000000000450', pyd_remarks = 'RC TMT' where pyd_number = 5962967
	*/
	
Open cursor_tmtpaydetails
FETCH NEXT FROM cursor_tmtpaydetails INTO @poinvoicid,@order, @ordernum, @unit ,@billed,@paid, @modifiedby, @drv,@callnum

WHILE @@fetch_status = 0

BEGIN


     select @msgtmt = isnull(' RoadCall:'+ @callnum ,'') +  ' Orden TMT: ' + @ordernum  
     select @leg = ( select top 1 lgh_number from  legheader where  lgh_outstatus in ('STD','DSP') and  lgh_driver1 = @drv )

	 print @msgtmt
	 print @leg

     exec [sp_insertaPayDetail_TMT]  @leg, 'DRV', @drv, @billed, @modifiedby, @msgtmt

	 
	--- Audit trail table for paydetails coming from TMT 
	print 'Insertando en Audit' 
    insert into  tmwams_auditpaydetail ([amspoinvoicid],[amsorderid],[amsordernumber] ,[suiteleg] ,[roadcall] ,[driver],[unidad] ,[amtbilled],[fechaanticipo])
    select  @poinvoicid, @order, @ordernum, @leg, @callnum,@drv,@unit,@billed,getdate()


    FETCH NEXT FROM cursor_tmtpaydetails INTO @poinvoicid,@order, @ordernum, @unit,@billed,@paid, @modifiedby, @drv,@callnum
END

CLOSE cursor_tmtpaydetails
DEALLOCATE cursor_tmtpaydetails




delete  paydetail where lgh_number = 1093596
  




GO
