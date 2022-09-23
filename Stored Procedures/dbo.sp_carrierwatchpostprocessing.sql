SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_carrierwatchpostprocessing]
	@CarrierCSALogHdr_id integer	
 AS
 
 declare @docket varchar(15)
 declare @car_id varchar(8)
 declare @dotnum varchar(20)
 declare @scac char(4)
 declare @emailaddress varchar(80)

 select @docket = c.docket from CarrierCSA c
	join CarrierCSALogDtl ch on c.docket = ch.docket
	where CarrierCSALogHdr_id = @CarrierCSALogHdr_id

 select @car_id = min(isnull(car_id, '')) from carrier where car_iccnum = @docket

 if @car_id = '' RETURN
 
 select @dotnum = dotnum, @scac = scac, @emailaddress = emailaddress from CarrierWatchMisc where @docket = docket
  
 update carrier
	set car_CarrierWatch_monitored = 'BAS'
	where car_id = @car_id
 
 update carrier
	set car_email = @emailaddress
	where car_id = @car_id
	AND car_email IS NULL OR car_email = ''
 
 update carrier
	set car_dotnum = @dotnum
	where car_id = @car_id
	AND car_dotnum IS NULL OR car_dotnum = ''
 
  update carrier
	set car_scac = @scac
	where car_id = @car_id
	AND car_scac IS NULL OR car_scac = ''
	
GO
GRANT EXECUTE ON  [dbo].[sp_carrierwatchpostprocessing] TO [public]
GO
