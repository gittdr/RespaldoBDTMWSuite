SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_finalstlreopenlist_sp] (
	@drvyes varchar(3),
	@trcyes varchar(3),
	@trlyes varchar(3),
	@caryes varchar(3),
	@company varchar(8),
	@fleet varchar(8),
	@division varchar(8),
	@terminal varchar(8),
	@drvtyp1 varchar(6),
	@drvtyp2 varchar(6),
	@drvtyp3 varchar(6),
	@drvtyp4 varchar(6),
	@trctyp1 varchar(6),
	@trctyp2 varchar(6),
	@trctyp3 varchar(6),
	@trctyp4 varchar(6),
	@trltyp1 varchar(6),
	@trltyp2 varchar(6),
	@trltyp3 varchar(6),
	@trltyp4 varchar(6),
	@cartyp1 varchar(6),
	@cartyp2 varchar(6),
	@cartyp3 varchar(6),
	@cartyp4 varchar(6),
	@driver varchar(8),
	@tractor varchar(8),
	@trailer varchar(13),
	@carrier varchar(8),
	@acct_typ char(1),
	@payperiod datetime,
	@tpryes varchar(3),
        @tpr varchar(8),
	@tprtyp1 char(1),
	@tprtyp2 char(1),
  	@tprtyp3 char(1),
	@tprtyp4 char(1),
	@tprtyp5 char(1),
	@tprtyp6 char(1))
 AS

/*
 *
 * NAME:
 * dbo.d_finalstlreopenlist_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for ReOpen Settlements->d_finalstlqueue_data
 *
 * RETURNS:
 *
 * RESULT SETS:
 * REVISION HISTORY:
 * 
 * PTS 52593 SPN 06/04/2010
 * PTS 66293 
 *
 */

--  PTS 66293.start
DECLARE @MPH TABLE (pyh_number int NULL, asgn_type varchar(6) null, asgn_id varchar(8) null )
declare @multicount int
declare @multiPHTrue varchar(8)
set		@multiPHTrue = 'N'
set		@multiPHTrue = (select 'Y' from generalinfo where gi_name = 'STLRELXFER' and gi_string1 = 'WHLTRP')
IF		@multiPHTrue is NULL set @multiPHTrue = 'N'

IF		@multiPHTrue <> 'Y'
	begin
		set @multiPHTrue = (select 'Y' from generalinfo where gi_name = 'StlUseBranchPerPYHNumber' and gi_string1 = 'Y')
		IF @multiPHTrue is NULL set @multiPHTrue = 'N'
	end
--  PTS 66293.end


/* Create a temporary table for data return set */
CREATE TABLE #tmp (
	pyh_number int not null,
	asgn_type varchar(6) not null,
 	asgn_id varchar(8) not null,
	pyh_paystatus varchar(6) not null,
	app_processed char(1) null ,			-- used in the application to indicate sucessful processing.
	app_description varchar(255) null,		-- used in the application to store the processing description
	ccMPH char(1) null )

/* Insert any drivers */
IF @drvyes != 'XXX'
BEGIN
   insert into #tmp (pyh_number,asgn_type,asgn_id,pyh_paystatus)	
   select pyh_pyhnumber, asgn_type,asgn_id,pyh_paystatus from payheader ,manpowerprofile 
    where (@driver = mpp_id OR @driver = 'UNKNOWN')
	  AND (mpp_id = asgn_id)	
          AND ( (@acct_typ = 'X' AND mpp_actg_type IN('A', 'P')) OR (@acct_typ = mpp_actg_type) )
          AND @company IN ('UNK', mpp_company) 
          AND @fleet IN ('UNK', mpp_fleet) 
          AND @division IN ('UNK', mpp_division) 
          AND @terminal IN ('UNK', mpp_terminal) 
          AND @drvtyp1 IN ('UNK', mpp_type1) 
          AND @drvtyp2 IN ('UNK', mpp_type2) 
          AND @drvtyp3 IN ('UNK', mpp_type3) 
          AND @drvtyp4 IN ('UNK', mpp_type4)
	  AND pyh_payperiod = @payperiod 
	  AND asgn_type = 'DRV' 
	  AND pyh_paystatus in ('COL','REL') -- collected and closed (rel is closed)
END

/* Insert any tractors */
IF @trcyes != 'XXX'
BEGIN
   insert into #tmp (pyh_number,asgn_type,asgn_id,pyh_paystatus)
   select pyh_pyhnumber, asgn_type,asgn_id,pyh_paystatus from payheader,tractorprofile 
    where (@tractor= trc_number OR @tractor = 'UNKNOWN')
	  AND (trc_number = asgn_id)	
          AND ( (@acct_typ = 'X' AND trc_actg_type IN('A', 'P')) OR (@acct_typ = trc_actg_type) )
          AND @company IN ('UNK', trc_company) 
          AND @fleet IN ('UNK', trc_fleet) 
          AND @division IN ('UNK', trc_division) 
          AND @terminal IN ('UNK', trc_terminal) 
-- BEGIN PTS 52593
--          AND @drvtyp1 IN ('UNK', trc_type1) 
--          AND @drvtyp2 IN ('UNK', trc_type2) 
--          AND @drvtyp3 IN ('UNK', trc_type3) 
--          AND @drvtyp4 IN ('UNK', trc_type4)
          AND @trctyp1 IN ('UNK', trc_type1) 
          AND @trctyp2 IN ('UNK', trc_type2) 
          AND @trctyp3 IN ('UNK', trc_type3) 
          AND @trctyp4 IN ('UNK', trc_type4)
-- END PTS 52593
	  AND pyh_payperiod = @payperiod 
	  AND asgn_type = 'TRC' 
	  AND pyh_paystatus in ('COL','REL') -- collected and closed (rel is closed)
END


/* Insert any trailers */
IF @trlyes != 'XXX'
BEGIN
   insert into #tmp (pyh_number,asgn_type,asgn_id,pyh_paystatus)	
   select pyh_pyhnumber, asgn_type,asgn_id,pyh_paystatus from payheader,trailerprofile 
    where (@trailer = trl_id OR @trailer = 'UNKNOWN')
	  AND (trl_id = asgn_id)	
          AND ( (@acct_typ = 'X' AND trl_actg_type IN('A', 'P')) OR (@acct_typ = trl_actg_type) )
          AND @company IN ('UNK', trl_company) 
          AND @fleet IN ('UNK', trl_fleet) 
          AND @division IN ('UNK', trl_division) 
          AND @terminal IN ('UNK', trl_terminal) 
-- BEGIN PTS 52593
--          AND @drvtyp1 IN ('UNK', trl_type1) 
--          AND @drvtyp2 IN ('UNK', trl_type2) 
--          AND @drvtyp3 IN ('UNK', trl_type3) 
--          AND @drvtyp4 IN ('UNK', trl_type4)
          AND @trltyp1 IN ('UNK', trl_type1) 
          AND @trltyp2 IN ('UNK', trl_type2) 
          AND @trltyp3 IN ('UNK', trl_type3) 
          AND @trltyp4 IN ('UNK', trl_type4)
-- END PTS 52593
	  AND pyh_payperiod = @payperiod 
	  AND asgn_type = 'TRL' 
	  AND pyh_paystatus in ('COL','REL') -- collected and closed (rel is closed)
END


/* Insert any carriers */
IF @caryes != 'XXX'
BEGIN
   insert into #tmp(pyh_number,asgn_type,asgn_id,pyh_paystatus)
   select pyh_pyhnumber, asgn_type,asgn_id,pyh_paystatus from payheader,carrier 
    where (@carrier = car_id OR @carrier = 'UNKNOWN')
	  AND (car_id = asgn_id)	
          AND ( (@acct_typ = 'X' AND car_actg_type IN('A', 'P')) OR (@acct_typ = car_actg_type) )
-- BEGIN PTS 52593
--          AND @drvtyp1 IN ('UNK', car_type1) 
--          AND @drvtyp2 IN ('UNK', car_type2) 
--          AND @drvtyp3 IN ('UNK', car_type3) 
--          AND @drvtyp4 IN ('UNK', car_type4)
          AND @cartyp1 IN ('UNK', car_type1) 
          AND @cartyp2 IN ('UNK', car_type2) 
          AND @cartyp3 IN ('UNK', car_type3) 
          AND @cartyp4 IN ('UNK', car_type4)
-- END PTS 52593
	  AND pyh_payperiod = @payperiod 
	  AND asgn_type = 'CAR' 
	  AND pyh_paystatus in ('COL','REL') -- collected and closed (rel is closed)
END

/* Insert any thirdparty */
IF @tpryes != 'XXX'
BEGIN
   insert into #tmp(pyh_number, asgn_type, asgn_id, pyh_paystatus)
   select pyh_pyhnumber, asgn_type, asgn_id, pyh_paystatus from payheader, thirdpartyprofile
   where (@tpr = tpr_id OR @tpr = 'UNKNOWN') 
         AND (tpr_id = asgn_id)
         AND ((@acct_typ = 'X' AND tpr_actg_type IN ('A','P')) OR (@acct_typ = tpr_actg_type))
         AND (@tprtyp1= tpr_thirdpartytype1 OR
                     @tprtyp2 = tpr_thirdpartytype2 OR
                     @tprtyp3 = tpr_thirdpartytype3 OR
                     @tprtyp4 = tpr_thirdpartytype4 OR
                     @tprtyp5 = tpr_thirdpartytype5 OR
                     @tprtyp6 = tpr_thirdpartytype6)
         AND pyh_payperiod = @payperiod
         AND asgn_type = 'TPR'
         AND pyh_paystatus IN ('COL','REL') -- collected and closed (rel is closed)
END

--select pyh_number, asgn_type,asgn_id,pyh_paystatus from #tmp
--  PTS 66293.start  //if any of the multi payheader GI's is enabled, do the process.
update #tmp set ccMPH = 'N'	

IF @multiPHTrue = 'Y' 
BEGIN
		select @multicount = count(distinct(pyh_number) )
		from #tmp
		group by #tmp.asgn_type,	#tmp.asgn_id
		having count(distinct(pyh_number) )  > 1		

		if @multicount > 0
		begin 
				insert into @MPH (asgn_type, asgn_id)
				select  asgn_type, asgn_id
				from #tmp
				group by asgn_type,	asgn_id
				having count(asgn_id)   > 1
		end 		

		update #tmp
		set ccMPH = 'Y'
		where #tmp.pyh_number in (select #tmp.pyh_number
								  from #tmp, @MPH mm
								  where #tmp.asgn_type = mm.asgn_type 
								  and #tmp.asgn_id = mm.asgn_id )
END

select pyh_number, asgn_type,	asgn_id,	pyh_paystatus,	app_processed 
from #tmp
order by asgn_type, asgn_id, pyh_number, pyh_paystatus
--  PTS 66293.end

GO
GRANT EXECUTE ON  [dbo].[d_finalstlreopenlist_sp] TO [public]
GO
