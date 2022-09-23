SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create procedure [dbo].[d_gross_transfer_rpt_sp]
		@vs_asgn_type	varchar(6)
		,@vs_type1		varchar(6)
		,@vdt_beg_pay	datetime
		,@vdt_end_pay	datetime
as
/**
 * 
 * NAME:
 * dbo.d_gross_transfer_rpt_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Retrieves data for the Gross Transfer Report (Settlements, Batch menu).
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @asgn_type	The type of resource to report on.    
 * 002 - @type1		The type1 value which limits the set of resources to report on.
 * 003 - @beg_pay	Earliest payperiod to report on.
 * 004 - @end_pay	Latest payperiod to report on.
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 06/27/2002	Vern Jewett		14626	(none)	Original.
 * 08/08/2005	jguo			29148		replace double quotes
 *
 **/

/* May not be needed..
create table #pay
		(asgn_type		varchar(6)		null
		,asgn_id		varchar(8)		null
		,pyd_payto		varchar(12)		null
		,pyt_itemcode	varchar(6)		null
		,pyd_quantity	float			null
		,pyd_rate		money			null
		,pyd_amount		money			null
		,pyd_pretax		char(1)			null
		,pyh_payperiod	datetime		null
		,pyd_number		int				null
		,pyh_pyhnumber	int				null)


create table #resource
		(asgn_type		varchar(6)		null
		,asgn_id		varchar(8)		null
		,resource_name	varchar(100)	null
		,otherid		varchar(20)		null
		,terminal		varchar(6)		null
		,type1			varchar(6)		null
		,userlabelname	varchar(20)		null
		,label_name		varchar(20)		null)
*/



--Warning to developers modifying this code: if you make a change to any of these cases,
--all of them must be changed..
if @vs_asgn_type = 'CAR'
	select	pd.asgn_type,
			pd.asgn_id,
			pd.pyd_payto,
			pd.pyt_itemcode,
			pd.pyd_quantity,
			pd.pyd_rate,
			round(pd.pyd_amount, 2) as pyd_amount,
			pd.pyd_pretax,
			pd.pyh_payperiod,
			pd.pyd_number,
			c.car_name as resource_name,
			c.car_otherid as otherid,
			'' as terminal,
			ph.pyh_pyhnumber,
			lf.userlabelname,
			lf.name as label_name,
			c.car_type1 as type1
	  from	payheader ph
			,paydetail pd
			,carrier c
			,labelfile lf
	  where	ph.asgn_type = @vs_asgn_type
		and	ph.pyh_payperiod between @vdt_beg_pay and @vdt_end_pay
		and	c.car_id = ph.asgn_id
		and	@vs_type1 in ('UNK', c.car_type1)
		and	pd.pyh_number = ph.pyh_pyhnumber
		and	lf.labeldefinition = 'CarType1'
		and lf.abbr = c.car_type1


else if @vs_asgn_type = 'DRV'
	select	pd.asgn_type,
			pd.asgn_id,
			pd.pyd_payto,
			pd.pyt_itemcode,
			pd.pyd_quantity,
			pd.pyd_rate,
			round(pd.pyd_amount, 2) as pyd_amount,
			pd.pyd_pretax,
			pd.pyh_payperiod,
			pd.pyd_number,
			isnull(mpp.mpp_lastname, '') + ', ' + isnull(mpp.mpp_firstname, '') 
				as resource_name,
			mpp.mpp_otherid as otherid,
			mpp.mpp_terminal as terminal,
			ph.pyh_pyhnumber,
			lf.userlabelname,
			lf.name as label_name,
			mpp.mpp_type1 as type1
	  from	payheader ph
			,paydetail pd
			,manpowerprofile mpp
			,labelfile lf
	  where	ph.asgn_type = @vs_asgn_type
		and	ph.pyh_payperiod between @vdt_beg_pay and @vdt_end_pay
		and	mpp.mpp_id = ph.asgn_id
		and	@vs_type1 in ('UNK', mpp.mpp_type1)
		and	pd.pyh_number = ph.pyh_pyhnumber
		and	lf.labeldefinition = 'DrvType1'
		and lf.abbr = mpp.mpp_type1


else if @vs_asgn_type = 'TRC'
	select	pd.asgn_type,
			pd.asgn_id,
			pd.pyd_payto,
			pd.pyt_itemcode,
			pd.pyd_quantity,
			pd.pyd_rate,
			round(pd.pyd_amount, 2) as pyd_amount,
			pd.pyd_pretax,
			pd.pyh_payperiod,
			pd.pyd_number,
			isnull(convert(varchar(4), tp.trc_year), '') + ' ' + isnull(tp.trc_make, '') + 
				' ' + isnull(tp.trc_model, '') as resource_name,
			tp.trc_serial as otherid,
			tp.trc_terminal as terminal,
			ph.pyh_pyhnumber,
			lf.userlabelname,
			lf.name as label_name,
			tp.trc_type1 as type1
	  from	payheader ph
			,paydetail pd
			,tractorprofile tp
			,labelfile lf
	  where	ph.asgn_type = @vs_asgn_type
		and	ph.pyh_payperiod between @vdt_beg_pay and @vdt_end_pay
		and	tp.trc_number = ph.asgn_id
		and	@vs_type1 in ('UNK', tp.trc_type1)
		and	pd.pyh_number = ph.pyh_pyhnumber
		and	lf.labeldefinition = 'TrcType1'
		and lf.abbr = tp.trc_type1


else if @vs_asgn_type = 'TRL'
	select	pd.asgn_type,
			pd.asgn_id,
			pd.pyd_payto,
			pd.pyt_itemcode,
			pd.pyd_quantity,
			pd.pyd_rate,
			round(pd.pyd_amount, 2) as pyd_amount,
			pd.pyd_pretax,
			pd.pyh_payperiod,
			pd.pyd_number,
			isnull(convert(varchar(4), tp.trl_year), '') + ' ' + isnull(tp.trl_make, '') + 
				' ' + isnull(tp.trl_model, '') as resource_name,
			tp.trl_serial as otherid,
			tp.trl_terminal as terminal,
			ph.pyh_pyhnumber,
			lf.userlabelname,
			lf.name as label_name,
			tp.trl_type1 as type1
	  from	payheader ph
			,paydetail pd
			,trailerprofile tp
			,labelfile lf
	  where	ph.asgn_type = @vs_asgn_type
		and	ph.pyh_payperiod between @vdt_beg_pay and @vdt_end_pay
		and	tp.trl_number = ph.asgn_id
		and	@vs_type1 in ('UNK', tp.trl_type1)
		and	pd.pyh_number = ph.pyh_pyhnumber
		and	lf.labeldefinition = 'TrlType1'
		and lf.abbr = tp.trl_type1


/* ORIGINAL SELECT
SELECT paydetail.asgn_type, 	
		paydetail.asgn_id, 	
		paydetail.pyd_payto, 	
		paydetail.pyt_itemcode, 	
		paydetail.pyd_quantity, 	
		paydetail.pyd_rate, 	
		pyd_amount = round ( paydetail.pyd_amount, 2 ), 	
		paydetail.pyd_pretax, 	
		paydetail.pyh_payperiod, 	
		paydetail.pyd_number,	
		manpowerprofile.mpp_lastname +', '+ manpowerprofile.mpp_firstname name, 	
		manpowerprofile.mpp_otherid, 	
		manpowerprofile.mpp_terminal, 	
		payheader.pyh_pyhnumber,
		l.userlabelname, 
		l.name, 
		manpowerprofile.mpp_type1 
FROM paydetail, manpowerprofile, payheader, labelfile l 
WHERE ( payheader.pyh_pyhnumber = paydetail.pyh_number ) and 	
		( payheader.asgn_type = 'DRV' ) and 	
		( payheader.pyh_payperiod between :beg_pay and :end_pay ) and 	
		( payheader.asgn_id = manpowerprofile.mpp_id ) and 	
		:type1 in ('UNK', manpowerprofile.mpp_type1 ) and 	
		l.labeldefinition = 'DrvType1' and 
		manpowerprofile.mpp_type1 = l.abbr	*/
GO
GRANT EXECUTE ON  [dbo].[d_gross_transfer_rpt_sp] TO [public]
GO
