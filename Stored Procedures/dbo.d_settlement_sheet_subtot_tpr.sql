SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_settlement_sheet_subtot_tpr] (@payperiodstart datetime,
						@payperiodend   datetime,
						@drv_yes        varchar(3),
						@trc_yes        varchar(3),
						@trl_yes        varchar(3),
						@drv_id         varchar(8),
						@trc_id         varchar(8),
						@trl_id         varchar(13),
						@drv_type1      varchar(6),
						@drv_type2      varchar(6),     
						@drv_type3      varchar(6),
						@drv_type4      varchar(6),
						@trc_type1      varchar(6),
						@trc_type2      varchar(6),     
						@trc_type3      varchar(6),
						@trc_type4      varchar(6),
						@trl_type1      varchar(6),
						@trl_type2      varchar(6),     
						@trl_type3      varchar(6),
						@trl_type4      varchar(6),
						@company        varchar(8),
						@fleet          varchar(8),
						@division       varchar(8),
						@domicile       varchar(8),
						@acct_type      char(1),
						@car_yes	varchar(3),
						@car_id		varchar(8),
						@car_type1	varchar(6),
						@car_type2	varchar(6),
						@car_type3	varchar(6),
						@car_type4	varchar(6),
						@tpr_yes	varchar(3),
						@tpr_yes1 	varchar(1),
						@tpr_yes2 	varchar(1),
						@tpr_yes3 	varchar(1),
						@tpr_yes4 	varchar(1),
						@tpr_yes5 	varchar(1),
						@tpr_yes6 	varchar(1),
						@tpr_id  	varchar(8) )
as 
/**
 * 
 * NAME:
 * dbo.d_settlement_sheet_subtot_tpr 
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001 -   
 * Calls002 -
 *
 * CalledBy001 -
 * CalledBy002 - 
 *
 * REVISION HISTORY:
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names.
 * 11/02/2007.01 ? PTS40116 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

declare @name 		varchar(50),
	@type6		varchar(6), 
	@lgh_number	int,
	@dummydate	datetime

SELECT 	payheader.pyh_pyhnumber, 
	payheader.asgn_type, 
	payheader.asgn_id, 
	@name paytoname, 	

	payheader.pyh_payperiod, 
	payheader.pyh_totalcomp,  
	payheader.pyh_totalreimbrs,  
	payheader.pyh_totaldeduct,  
	@name name,   
	@type6 company,
	@type6 fleet,
	@type6 division,
	@type6 terminal ,
	@payperiodstart payperiodstart,
	@payperiodend payperiodend
INTO #tt   
FROM payheader 
where 1 = 2 

                                                
if (@drv_yes <> 'XXX') 
BEGIN
	INSERT INTO #tt 
	SELECT 	payheader.pyh_pyhnumber, 
		payheader.asgn_type, 
		payheader.asgn_id, 
		payto.pto_lastfirst + '  ' + payheader.pyh_payto, 
		payheader.pyh_payperiod, 
		payheader.pyh_totalcomp,  
		payheader.pyh_totalreimbrs,  
		payheader.pyh_totaldeduct,  
		manpowerprofile.mpp_lastname + ', ' + manpowerprofile.mpp_firstname name,   
		manpowerprofile.mpp_company,
		manpowerprofile.mpp_fleet,
		manpowerprofile.mpp_division,
		manpowerprofile.mpp_terminal,
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id,
	     manpowerprofile
	WHERE ( payheader.asgn_type = 'DRV' ) AND  
		( payheader.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
		@drv_id in ( 'UNKNOWN', payheader.asgn_id) and 
		payheader.asgn_id = manpowerprofile.mpp_id and 
		@drv_type1 in ('UNK', manpowerprofile.mpp_type1) and 
		@drv_type2 in ('UNK', manpowerprofile.mpp_type2) and 
		@drv_type3 in ('UNK', manpowerprofile.mpp_type3) and 
		@drv_type4 in ('UNK', manpowerprofile.mpp_type4) and 
		@company in ('UNK',manpowerprofile.mpp_company) and
		@fleet in ('UNK', manpowerprofile.mpp_fleet) and 
		@division in ( 'UNK', manpowerprofile.mpp_division) and
		@domicile in ('UNK', manpowerprofile.mpp_domicile ) and
		@acct_type in ('X', manpowerprofile.mpp_actg_type)

END

if (@trc_yes <> 'XXX') 
BEGIN
	INSERT INTO #tt
	SELECT 	payheader.pyh_pyhnumber, 
		payheader.asgn_type, 
		payheader.asgn_id, 
		payto.pto_lastfirst + '  ' + payheader.pyh_payto, 
		payheader.pyh_payperiod, 
		payheader.pyh_totalcomp,  
		payheader.pyh_totalreimbrs,  
		payheader.pyh_totaldeduct,  
		payto.pto_lastfirst, 
		tractorprofile.trc_company,
		tractorprofile.trc_fleet,
		tractorprofile.trc_division,
		tractorprofile.trc_terminal,
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id, 
		 tractorprofile 
	WHERE ( payheader.asgn_type = 'TRC' ) AND  
		( payheader.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
		@trc_id in ( 'UNKNOWN', payheader.asgn_id) and 
		payheader.asgn_id = tractorprofile.trc_number and 
		@trc_type1 in ('UNK', tractorprofile.trc_type1) and 
		@trc_type2 in ('UNK', tractorprofile.trc_type2) and 
		@trc_type3 in ('UNK', tractorprofile.trc_type3) and 
		@trc_type4 in ('UNK', tractorprofile.trc_type4) and 
		@company in ('UNK',tractorprofile.trc_company) and
		@fleet in ('UNK', tractorprofile.trc_fleet) and 
		@division in ( 'UNK', tractorprofile.trc_division) and
		@domicile in ('UNK', tractorprofile.trc_terminal ) and
		@acct_type in ('X', tractorprofile.trc_actg_type)
END

/* Added carrier handling 2/8/96 WSC */
if (@car_yes <> 'XXX') 
BEGIN
	INSERT INTO #tt

	SELECT 	payheader.pyh_pyhnumber, 
		payheader.asgn_type, 
		payheader.asgn_id, 
		payto.pto_lastfirst + '  ' + payheader.pyh_payto, 
		payheader.pyh_payperiod, 
		payheader.pyh_totalcomp,  
		payheader.pyh_totalreimbrs,  
		payheader.pyh_totaldeduct,  
		payto.pto_lastfirst, 
		'',
		'',
		'',
		'',
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id, 
		 carrier
	WHERE ( payheader.asgn_type = 'CAR' ) AND  
		( payheader.pyh_payperiod between @payperiodstart and @payperiodend ) AND  
		@car_id in ( 'UNKNOWN', payheader.asgn_id) and 
		payheader.asgn_id = carrier.car_id and 
		@car_type1 in ('UNK', carrier.car_type1) and 
		@car_type2 in ('UNK', carrier.car_type2) and 
		@car_type3 in ('UNK', carrier.car_type3) and 
		@car_type4 in ('UNK', carrier.car_type4) and 
		@acct_type in ('X', carrier.car_actg_type)

END

/* Added thirdparty handling 1/8/99 */
if (@tpr_yes <> 'XXX') 
BEGIN
	INSERT INTO #tt

	SELECT 	payheader.pyh_pyhnumber, 
		payheader.asgn_type, 
		payheader.asgn_id, 
		payto.pto_lastfirst + '  ' + payheader.pyh_payto, 
		payheader.pyh_payperiod, 
		payheader.pyh_totalcomp,  
		payheader.pyh_totalreimbrs,  
		payheader.pyh_totaldeduct,  
		payto.pto_lastfirst, 
		'',
		'',
		'',
		'',
		@payperiodstart payperiodstart,
		@payperiodend payperiodend
	FROM payheader LEFT OUTER JOIN payto ON payheader.pyh_payto = payto.pto_id, 
		 thirdpartyprofile
	WHERE ( payheader.asgn_type = 'TPR' ) AND  
		( payheader.pyh_payperiod between @payperiodstart and @payperiodend ) 
		AND payheader.asgn_id = tpr_id 
		AND ((@tpr_id = tpr_id and @tpr_id not in ('UNKNOWN')) OR
			(@tpr_id = 'UNKNOWN' and
			(tpr_thirdpartytype1 = @tpr_yes1 or tpr_thirdpartytype1 is null) and
			(tpr_thirdpartytype2 = @tpr_yes2 or tpr_thirdpartytype2 is null) and
			(tpr_thirdpartytype3 = @tpr_yes3 or tpr_thirdpartytype3 is null) and
			(tpr_thirdpartytype4 = @tpr_yes4 or tpr_thirdpartytype4 is null) and
			(tpr_thirdpartytype5 = @tpr_yes5 or tpr_thirdpartytype5 is null) and
			(tpr_thirdpartytype6 = @tpr_yes6 or tpr_thirdpartytype6  is null))) and
		@acct_type in ('X', tpr_actg_type)
END

SELECT 	pyh_pyhnumber, 
	asgn_type, 

	asgn_id, 
	paytoname, 	
	pyh_payperiod, 
	round ( pyh_totalcomp, 2),  
	round ( pyh_totalreimbrs, 2),  
	round ( pyh_totaldeduct, 2),  
	name,   
	company,
	fleet,
	division,
	terminal,
	payperiodstart,
	payperiodend
from #tt 

return

GO
GRANT EXECUTE ON  [dbo].[d_settlement_sheet_subtot_tpr] TO [public]
GO
