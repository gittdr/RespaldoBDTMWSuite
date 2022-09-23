SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[Stl_postprocess001_sp]
		(@lghnumber 				int, @OnFault varchar(20))
AS
/* Post Process type 001 is for Sodrel who creates and negative pay adjustment
  If the arrive time at a BMT or BBT is later thant the grace period doe th driver
  and creates a negatice pay adjustment if the depart time from AN EMT or EBT is earlier than
  that same grace period

DPETE 7/16/03 Change use of an existing field to tag recores added by post process
     to a field added for that purpose  pyd_PostProcSource when = 1 was added by this proc
*/
Declare @allowance int, @minslate int, @minsearly int, @pydnumber int,@nextpydnumber int,@nextseq int,
   @increments int,@14mins int, @15mins int, @adjqty dec(9,2),@reason varchar(6), @startcode smallint, @endcode smallint

Select @onFault = IsNull(Upper(@OnFault),'ANY')
Select @startcode = Case @OnFault When 'CARRIER' Then 1 When 'COMPANY' Then 101 else 1 End
Select @endcode = Case @OnFault When 'CARRIER' Then 100 When 'COMPANY' Then 200 else 0 End

  If Exists (Select pyd_amount From paydetail,paytype 
       Where paydetail.lgh_number = @lghnumber and  paytype.pyt_itemcode = paydetail.pyt_itemcode
       and paytype.pyt_basis = 'LGH'
       and paydetail.pyd_unit = 'HRS' and paydetail.pyd_amount <> 0
       and paydetail.asgn_type = 'DRV'
    	 and paydetail.pyd_status = 'HLD'
       and paydetail.pyd_amount > 0
       and IsNull(pyd_PostProcSource,0) <> 1)

    BEGIN -- segment pay exists 

       -- remove already exisitng pay adjustments (updatedby gets overlayed with a trigger)
       Delete From paydetail Where lgh_number = @lghnumber and pyd_PostProcSource =  1

       Select @pydnumber = pyd_number 
       From paydetail,paytype 
       Where paydetail.lgh_number = @lghnumber and  paytype.pyt_itemcode = paydetail.pyt_itemcode
       and paytype.pyt_basis = 'LGH'
       and paydetail.pyd_unit = 'HRS' and paydetail.pyd_amount <> 0
       and paydetail.asgn_type = 'DRV'
    	 and paydetail.pyd_status = 'HLD'
       and paydetail.pyd_amount > 0

       -- look for a late arrival
       Select @allowance = IsNull( mpp_arvdep_allowance_mins,9999) 
       From manpowerprofile m,paydetail p
       Where p.pyd_number  = @pydnumber
       and m.mpp_id = p.asgn_id

       -- did he arrive late at the first stop?
       Select @minslate = Datediff(mi,stp_schdtearliest,stp_arrivaldate) - @allowance,@reason = stp_reasonlate
       From stops
       Where lgh_number = @lghnumber
       And stops.stp_mfh_sequence = 1
       and stops.stp_event in ('BMT','BBT')
       Select @minslate = IsNull(@minslate,0)

       -- If @OnFault = carrier check reasonlate code in labelfile
       If @minslate > 0 and @OnFault in ( 'CARRIER','COMPANY')
         BEGIN
           If (Select code From labelfile Where labeldefinition = 'ReasonLate' and abbr = @reason) Between @startcode And @endcode
              Select @minslate = @minslate
           Else
              Select @minslate = 0
         END

       -- did he depart early
       Select @minsearly = Datediff(mi,stp_departuredate,stp_schdtlatest) - @allowance,@reason = stp_reasonlate_depart
       From stops 
       Where lgh_number = @lghnumber
       And stp_mfh_sequence = (Select max(stp_mfh_sequence) From stops s2 where s2.lgh_number = @lghnumber)
       And stp_event in ('EMT','EBT')
       Select @minsearly = IsNull(@minsearly,0)

        If @minsearly > 0 and @OnFault in ( 'CARRIER','COMPANY')
         BEGIN
           If (Select code From labelfile Where labeldefinition = 'ReasonLate' and abbr = @reason) Between @startcode And @endcode
              Select @minsearly = @minsearly
           Else
              Select @minsearly = 0
         END

       If @minsearly > 0 or @minslate > 0
         BEGIN  -- early or late, uste create adj
           Select @nextseq = Max(pyd_sequence) + 1 From paydetail
           Where lgh_number = @lghnumber
           Select @14mins = 14,@15mins = 15
           If @minsearly > 0 and @minslate > 0 
              	Exec @nextpydnumber =  getsystemnumberblock 'PYDNUM',NULL,2
           Else
               Exec @nextpydnumber =  getsystemnumberblock 'PYDNUM',NULL,1

           If @minslate > 0
             BEGIN  -- create adj for late arrival
               Select @increments = (@minslate + @14mins) / @15mins
               Select @adjqty = (@increments * -.25)

               Insert Into paydetail (pyd_number,pyh_number,lgh_number,asgn_number,asgn_type,asgn_id,  --1
               ivd_number,pyd_prorap,pyd_payto,pyt_itemcode,mov_number,pyd_description,pyr_ratecode,pyd_quantity, --2
               pyd_rateunit,pyd_unit,pyd_rate,pyd_amount,pyd_pretax,pyd_glnum,pyd_currency,pyd_currencydate, --3
               pyd_status,pyh_payperiod,pyd_workperiod,lgh_startpoint,lgh_startcity,lgh_endpoint,lgh_endcity, --4
               ivd_payrevenue,pyd_revenueratio,pyd_lessrevenue,pyd_payrevenue,pyd_transdate,pyd_minus,pyd_sequence, --5
               std_number,pyd_loadstate,pyd_xrefnumber,ord_hdrnumber,pyt_fee1,pyt_fee2,pyd_grossamount,pyd_adj_flag, --6
               pyd_updatedby,psd_id,pyd_updatedon,pyd_PostProcSource)  --7
               Select @nextpydnumber,pyh_number,lgh_number,asgn_number,asgn_type,asgn_id, --1
               ivd_number,pyd_prorap,pyd_payto,pyt_itemcode,mov_number,pyd_description + ' (Late Arv Adj)',pyr_ratecode, @adjqty, --2
               pyd_rateunit,pyd_unit,pyd_rate,Round(@adjqty * pyd_rate,2),pyd_pretax,pyd_glnum,pyd_currency,pyd_currencydate, --3
               pyd_status,pyh_payperiod,pyd_workperiod,lgh_startpoint,lgh_startcity,lgh_endpoint,lgh_endcity, --4
               ivd_payrevenue=.0,pyd_revenueratio=0.0,pyd_lessrevenue=.0,pyd_payrevenue=.0,getdate(),pyd_minus,@nextseq, --5
               std_number,pyd_loadstate,pyd_xrefnumber,ord_hdrnumber,pyt_fee1=.0,pyt_fee2=.0,Round(@adjqty * pyd_rate,2),'N',  --6
               'PostProc',psd_id,getdate(),1
               From paydetail Where pyd_number = @pydnumber
               
               Select @nextseq = @nextseq + 1,@nextpydnumber = @nextpydnumber + 1
             END    -- create adj for late arrival
             If @minsearly > 0
             BEGIN  -- create adj for early departure
               Select @increments = (@minsearly + @14mins) / @15mins
               Select @adjqty = (@increments * -.25)
               Insert Into paydetail (pyd_number,pyh_number,lgh_number,asgn_number,asgn_type,asgn_id,  --1
               ivd_number,pyd_prorap,pyd_payto,pyt_itemcode,mov_number,pyd_description,pyr_ratecode,pyd_quantity, --2
               pyd_rateunit,pyd_unit,pyd_rate,pyd_amount,pyd_pretax,pyd_glnum,pyd_currency,pyd_currencydate, --3
               pyd_status,pyh_payperiod,pyd_workperiod,lgh_startpoint,lgh_startcity,lgh_endpoint,lgh_endcity, --4
               ivd_payrevenue,pyd_revenueratio,pyd_lessrevenue,pyd_payrevenue,pyd_transdate,pyd_minus,pyd_sequence, --5
               std_number,pyd_loadstate,pyd_xrefnumber,ord_hdrnumber,pyt_fee1,pyt_fee2,pyd_grossamount,pyd_adj_flag, --6
               pyd_updatedby,psd_id,pyd_updatedon,pyd_PostProcSource)  --7
               Select @nextpydnumber,pyh_number,lgh_number,asgn_number,asgn_type,asgn_id, --1
               ivd_number,pyd_prorap,pyd_payto,pyt_itemcode,mov_number,pyd_description + ' (Early Dep Adj)',pyr_ratecode, @adjqty, --2
               pyd_rateunit,pyd_unit,pyd_rate,Round(@adjqty * pyd_rate,2),pyd_pretax,pyd_glnum,pyd_currency,pyd_currencydate, --3
               pyd_status,pyh_payperiod,pyd_workperiod,lgh_startpoint,lgh_startcity,lgh_endpoint,lgh_endcity, --4
               ivd_payrevenue=.0,pyd_revenueratio=0.0,pyd_lessrevenue=.0,pyd_payrevenue=.0,getdate(),pyd_minus,@nextseq, --5
               std_number,pyd_loadstate,pyd_xrefnumber,ord_hdrnumber,pyt_fee1=.0,pyt_fee2=.0,Round(@adjqty * pyd_rate,2),'N',  --6
               'PostProc',psd_id,getdate(),1
               From paydetail Where pyd_number = @pydnumber
             END    -- create adj for early departure
         END   -- early or late,  create adj 

    END  -- segment pay exists

--  END -- post process 001 applies


GO
GRANT EXECUTE ON  [dbo].[Stl_postprocess001_sp] TO [public]
GO
