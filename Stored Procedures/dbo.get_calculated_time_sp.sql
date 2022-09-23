SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[get_calculated_time_sp] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_lgh_number int, -- the current trip segment being settled
	@pl_isprimary int, -- 0 or 1, 1 indicates that the time is being requested for linehaul settlement rate
	@ps_asgn_type varchar(6), -- indicates the type of asset, you can put conditional logic to determine rates based on this type
	@ps_asgn_id varchar(13), -- indicates the id of the asset
	@ps_paytype varchar(6), -- the paytype that the application found on the rate that time needs calculation
	@pl_tarnum int, -- the tariff number on the rate being used
	@ps_time_calc varchar(6), -- time calculation method from the tariff
	@pl_disallowzeropaydetail int out, -- If you set this to 1 and the calc time is zero the app will not create a zero paydetail.
									-- If you set this to 2 and @pl_isprimary=0 (non-LH rate) and the calc time is zero the app will use standard TMW time logic
	@ps_returnmsg varchar(255) out, -- You should return a message to the application to indicate why the custom calculation failed.
	@pdec_calctime money out) -- return the calculated time here. Populate this with -1 if the calculation fails			

as 

	declare @first_stop int 
	declare @last_stop int
	declare @first_arrive datetime  
	declare @last_depart datetime
	declare @first_depart datetime  
	declare @last_arrive datetime

select @pdec_calctime = -1
select @ps_returnmsg = 'No custom time calculation is currently supported.'
select @pl_disallowzeropaydetail = 0

-- The following code is a prototype of the proposed method of generating custom calculated time


 if @pl_isprimary = 1 
 begin
  -- write code here to get the linehaul time. You must set @pdec_calctime to the time amount
	If @ps_time_calc = 'ARRDEP'
	Begin
		set @pdec_calctime = 0
		set @first_stop=(select stp_number 
								from stops 
								where lgh_number=@pl_lgh_number 
								and stp_mfh_sequence=(select min(stp_mfh_sequence) 
													from stops 
													where lgh_number=@pl_lgh_number))
		
		set @last_stop=(select stp_number 
								from stops 
								where lgh_number=@pl_lgh_number 
								and stp_mfh_sequence=(select max(stp_mfh_sequence) 
													from stops 
													where lgh_number=@pl_lgh_number))
		
		set @first_arrive=(select stp_arrivaldate 
							from stops 
							where stp_number=@first_stop)


		set @last_depart=(select stp_departuredate 
							from stops 
							where stp_number=@last_stop)

		select @pdec_calctime = convert(decimal(10,4), convert(decimal(10,4), datediff(mi, @first_arrive, @last_depart)) / 60)
		set @ps_returnmsg = ''
	end 
	If @ps_time_calc = 'DEPARR'
	Begin
		set @pdec_calctime = 0
		set @first_stop=(select stp_number 
								from stops 
								where lgh_number=@pl_lgh_number 
								and stp_mfh_sequence=(select min(stp_mfh_sequence) 
													from stops 
													where lgh_number=@pl_lgh_number))
		
		set @last_stop=(select stp_number 
								from stops 
								where lgh_number=@pl_lgh_number 
								and stp_mfh_sequence=(select max(stp_mfh_sequence) 
													from stops 
													where lgh_number=@pl_lgh_number))
		
		set @first_depart=(select stp_departuredate 
							from stops 
							where stp_number=@first_stop)


		set @last_arrive=(select stp_arrivaldate 
							from stops 
							where stp_number=@last_stop)

		select @pdec_calctime = convert(decimal(10,4), convert(decimal(10,4), datediff(mi, @first_depart, @last_arrive)) / 60)
		set @ps_returnmsg = ''
	end 
 end 
-- else
-- begin
  -- write code here to get the accessorial time. You must set @pdec_calcrevenue to the time amount
-- end


GO
GRANT EXECUTE ON  [dbo].[get_calculated_time_sp] TO [public]
GO
