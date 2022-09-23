SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[TRANSF_V001_SP] (
	@pl_ord_hdrnumber int , -- the current order being settled 
	@pl_lgh_number int, -- the current trip segment being settled
	@pl_isprimary int, -- 0 or 1, 1 indicates that the revenue is being requested for linehaul settlement rate
	@ps_asgn_type varchar(6), -- indicates the type of asset, you can put conditional logic to determine rates based on this type
	@ps_asgn_id varchar(13), -- indicates the id of the asset
	@ps_paytype varchar(6), -- the paytype that the application found on the calculated revenue rate
	@pl_tarnum int, -- the tariff number on the rate being used
	@pl_disallowzeropaydetail int out, -- If you set this to 1 and the calc revenue is zero the app will not create a zero paydetail.
	@ps_returnmsg varchar(255) out, -- You should return a message to the application to indicate why the custom calculation failed.
	@pdec_calcrevenue money out, -- return the calculated revenue here. Populate this with -1 if the calculation fails
	@ps_loadstate varchar(3) OUT, -- Return the Load Status
	@pdc_rate decimal OUT -- Return the Rate
	
					)
as 
/**
 *
 * COMMENTS:
	'TRANSF'	Coded by BYOUNG
**/

select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'

/*  
* BEGIN TRANSF  
* Includes PTS 37718
*/  

Begin  
 if @pl_isprimary = 1   
 begin  
	 if @ps_paytype = 'STDHRS'  
		 BEGIN  
		   SELECT @pdec_calcrevenue =   
		  (  
		   SELECT  	isNull(sum(isNull(ord_cmdvalue,0)),0)  
		     FROM 	orderheader  
		    WHERE 	ord_hdrnumber = @pl_ord_hdrnumber  
		  )  
		 ENd   -- end STDHRS
		  
	 if @ps_paytype = 'ALLMIL'  
		 BEGIN  
		   SELECT @pdec_calcrevenue =   
		  (  
		   SELECT  	isNull(sum(isNull(stp_lgh_mileage,0)),0)  
		     FROM 	stops  
		    WHERE 	lgh_number = @pl_lgh_number  
		  )  
		 ENd  -- END ALLMIL
	 if @ps_paytype = 'LGHCST'  
		 BEGIN  
		   SELECT @pdec_calcrevenue =   
		  (  
		   SELECT  	isNull(sum(isNull(lgh_cost,0)),0)  
		     FROM 	legheader
		    WHERE 	lgh_number = @pl_lgh_number  
		  )  
		 ENd  -- END LGHCST
 end --END IF PRIMARY   
--SECONDARIES 
if @pl_isprimary != 1   
 begin  
	 if @ps_paytype = 'ALMILA'  
	 BEGIN  
	   SELECT @pdec_calcrevenue =   
	  (  
	   SELECT  isNull(sum(isNull(stp_lgh_mileage,0)),0)  
	     FROM stops  
	    WHERE lgh_number = @pl_lgh_number  
	  )  
	 ENd  --END ALMILA
--start PTS 36648
	 if @ps_paytype = 'HAZFLT'  
	 BEGIN  
		--need to check for the HAZM Load Requirement on the Order
		if (select count(*) from loadrequirement where ord_hdrnumber = @pl_ord_hdrnumber and lrq_type = 'HAZM') > 0
			begin
		   		SELECT @pdec_calcrevenue =  1 
			end
		else
			begin
				SELECT @pdec_calcrevenue =  0 , @pl_disallowzeropaydetail = 1, @ps_returnmsg = 'Error calculating HazMat Flat Pay'
			end
	 ENd  --END HAZFLT
	 if @ps_paytype = 'HAZMIL'  
	 BEGIN  
		--need to check for the HAZM Load Requirement on the Order
		if (select count(*) from loadrequirement where ord_hdrnumber = @pl_ord_hdrnumber and lrq_type = 'HAZM') > 0
			begin
			   SELECT @pdec_calcrevenue =   
			  (  
			   SELECT  isNull(sum(isNull(stp_lgh_mileage,0)),0)  
			     FROM stops  
			    WHERE lgh_number = @pl_lgh_number  
			  )  
			end
		else
			begin
				select	@pdec_calcrevenue = 0, @pl_disallowzeropaydetail = 1, @ps_returnmsg = 'Error calculating HazMat Per Mile Pay'
			end
	 ENd  --END HAZMIL
	 if @ps_paytype = 'BRDCAN'  
	 BEGIN  
	   SELECT @pdec_calcrevenue = 
	  (  
	   SELECT  	isNull(isNull(convert(money,ord_extrainfo9),0),0)  
	     FROM 	orderheader  
	    WHERE 	ord_hdrnumber = @pl_ord_hdrnumber  
	  )  
		select	@pl_disallowzeropaydetail = 1
	 ENd  --END BRDCAN
	if @ps_paytype = 'BRDMEX'  
	 BEGIN  
	   SELECT @pdec_calcrevenue = 
	  (  
	   SELECT  	isNull(isNull(convert(money,ord_extrainfo10),0),0)  
	     FROM 	orderheader  
	    WHERE 	ord_hdrnumber = @pl_ord_hdrnumber  
	  ) 
		select	@pl_disallowzeropaydetail = 1   
	 ENd  --END BRDMEX
	if @ps_paytype = 'TEAM'  
	 BEGIN  
		--need to check for the TEAM Load Requirement on the order
		if (select count(*) from loadrequirement where ord_hdrnumber = @pl_ord_hdrnumber and lrq_type = 'TEAM') > 0
		begin
		   SELECT @pdec_calcrevenue =   
		  (  
		   SELECT  isNull(sum(isNull(stp_lgh_mileage,0)),0)  
		     FROM stops  
		    WHERE lgh_number = @pl_lgh_number  
		  )  
		end
		else
		begin
			select	@pdec_calcrevenue = 0, @pl_disallowzeropaydetail = 1, @ps_returnmsg = 'Error calculating Team Pay'
		end
	 ENd  --END TEAM
--end PTS 36648
 end --END SECONDARIES  
End   
/*  
* END TRANSF  
*/   

GO
GRANT EXECUTE ON  [dbo].[TRANSF_V001_SP] TO [public]
GO
