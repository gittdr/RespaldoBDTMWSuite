SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[GSTTS_V001_SP] (
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
	'GSTTS'		vjh 32466
			vjh 41371 changes coded by client
**/

select @pdec_calcrevenue = -1
select @ps_returnmsg = 'No custom revenue method is currently supported.Custom calculated revenue methods are added based on customer requested billable Service Requests.'


-- BEGIN GSTTS

Begin
 IF @ps_paytype = 'CBHAUL' BEGIN
    --count orders with revtype3=BHAUL
    select @pdec_calcrevenue = 
      count(ord_hdrnumber) 
      from orderheader 
      where ord_hdrnumber in (select distinct(ord_hdrnumber) from stops where lgh_number=@pl_lgh_number and stp_event='LLD')
      and ord_revtype3='BKHAUL'
  END ELSE IF @ps_paytype = 'CFHAUL' BEGIN
    --count orders with revtype3=FHAUL
    select @pdec_calcrevenue = 
      (select count(ord_hdrnumber) 
      from orderheader 
      where ord_hdrnumber in (select distinct(ord_hdrnumber) from stops where lgh_number=@pl_lgh_number and (stp_event='LLD' or stp_event='LUL'))
      and ord_revtype3='FTHAUL')
	+
      (select count(ord_hdrnumber) 
      from orderheader 
      where ord_hdrnumber in (select distinct(ord_hdrnumber) from stops where lgh_number=@pl_lgh_number and stp_event='XDL'))
  END ELSE IF @ps_paytype = 'COLT30' BEGIN
        --count orders with origin to destination miles < 30
    select @pdec_calcrevenue = 
      count(ord_hdrnumber) 
      from orderheader 
      where ord_hdrnumber in (select distinct(ord_hdrnumber) from stops where lgh_number=@pl_lgh_number and stp_event in ('LUL','XDU'))
      and ord_totalmiles < 30
  END ELSE IF @ps_paytype = 'COGT50' BEGIN
    --count orders with origin to destination miles between > 50
    select @pdec_calcrevenue = 
      count(ord_hdrnumber) 
      from orderheader 
      where ord_hdrnumber in (select distinct(ord_hdrnumber) from stops where lgh_number=@pl_lgh_number and stp_event in ('LUL','XDU'))
      and ord_totalmiles >= 50
  END ELSE IF @ps_paytype = 'CO3050' BEGIN
    --count orders with origin to destination miles between 30 and 50	
    select @pdec_calcrevenue = 
      count(ord_hdrnumber) 
      from orderheader 
      where ord_hdrnumber in (select distinct(ord_hdrnumber) from stops where lgh_number=@pl_lgh_number and stp_event in ('LUL','XDU'))
      and ord_totalmiles >= 30
      and ord_totalmiles < 50
  END ELSE IF @ps_paytype = 'CSDROP' BEGIN
    --count stops that have a live load, live unload, crossdock or split event, new modification by FIT_GSTTS to correst skid drop issues
		DECLARE @company varchar(20)
	DECLARE @tmpcompany varchar(20)
	DECLARE @stopevent varchar(3)
	DECLARE @sequence int
	DECLARE @count int
	--Start with 1, there is always records when this sql is fired
	SET @count = 1

	DECLARE LEGCURSOR CURSOR FOR
	select s.cmp_id , s.stp_event , Max(stp_mfh_sequence) from stops s 
	join event e on s.stp_number = e.stp_number
    	where s.lgh_number = @pl_lgh_number

    	and e.evt_eventcode in ('LLD','LUL','XDL','XDU','PLD','DLT','BBT') 
	GROUP BY s.cmp_id , s.stp_event
	ORDER BY Max(stp_mfh_sequence)

	OPEN LEGCURSOR
	FETCH NEXT FROM LEGCURSOR INTO @company, @stopevent, @sequence
	WHILE (1 = 1)
	BEGIN
		IF @@FETCH_STATUS = -1 
		BEGIN
			BREAK
		END
		SET @tmpcompany = @company

		FETCH NEXT FROM LEGCURSOR INTO @company, @stopevent, @sequence 
		--PRINT CONVERT(varchar(10),@tmpcompany) + ' = '+ CONVERT(varchar(10),@company)
		IF @tmpcompany <> @company SET @count = @count + 1
	END
	CLOSE LEGCURSOR
	DEALLOCATE LEGCURSOR

	SET @pdec_calcrevenue = @count

 --   select @pdec_calcrevenue = 
 --     count(distinct(s.cmp_id)) from stops s join event e on s.stp_number = e.stp_number
 --     where s.lgh_number=@pl_lgh_number
 --    and e.evt_eventcode in ('LLD','LUL','XDL','XDU','PLD','DLT','BBT') 
  END ELSE IF @ps_paytype = 'CTOTAL' BEGIN
    --count the orders on this leg for the total number of units
    select @pdec_calcrevenue = count(distinct(ord_hdrnumber)) from stops where lgh_number=@pl_lgh_number and ord_hdrnumber <> 0 and stp_event in ('LUL','XDU')
  END ELSE select @ps_returnmsg = 'Paytype not supported'	
End

-- END GSTTS
--


GO
GRANT EXECUTE ON  [dbo].[GSTTS_V001_SP] TO [public]
GO
