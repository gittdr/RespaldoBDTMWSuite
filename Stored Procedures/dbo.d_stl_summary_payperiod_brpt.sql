SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--execute d_stl_summary_payperiod_brpt '01/22/00,DRV,GARTH'

Create Procedure [dbo].[d_stl_summary_payperiod_brpt]

	(
	@stringparm varchar (255)
	)
AS
/**
 * 
 * NAME:
 * dbo.d_stl_summary_payperiod_brpt
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
 *
 **/

DECLARE	
		
		@payperiod 	datetime,
		@asgntype	varchar(10),
		@asgnID	varchar(10)
		
Select @payperiod = convert( datetime, SUBSTRING(@stringparm, 1, PATINDEX('%,%', @stringparm) -1))
SELECT @stringparm = RTRIM(LTRIM(SUBSTRING(@stringparm, PATINDEX('%,%', @stringparm) + 1, LEN(@stringparm))))
Select @asgntype = RTRIM(LTRIM(SUBSTRING(@stringparm, 1, PATINDEX('%,%', @stringparm) -1)))
SELECT @stringparm = RTRIM(LTRIM(SUBSTRING(@stringparm, PATINDEX('%,%', @stringparm) + 1, LEN(@stringparm))))
Select @asgnID = RTRIM(LTRIM(@stringparm))

select asgn_id, sum(pyd_amount) as 'TotalMileagePay' 
Into #stltemp
from paydetail
where 	pyt_itemcode IN ('TSM', 'MTRATE') and 
	pyh_payperiod = @payperiod
group by asgn_id

select 	convert (varchar(10),pyh_payperiod,1) 'Pay Period', 
	p1.asgn_type, 
	p1.asgn_id,
	p1.pyt_itemcode ,
	sum(p1.pyd_amount) 'Total Pay', 
	#stltemp.totalmileagepay,
	
	isnull((select sum(stops.stp_lgh_mileage) 
		from stops where lgh_number IN(select lgh_number 
		from paydetail p2 
     		where p1.asgn_id = p2.asgn_id and 
     		p2.pyh_payperiod = @payperiod) and
     		isnull(stp_lgh_mileage, 0) >0), 0) 'Total Miles',

	isnull((select sum(stops.stp_lgh_mileage) 
 		from stops where lgh_number IN(select lgh_number 
     		from paydetail p2 
     		where p1.asgn_id = p2.asgn_id and 
     		p2.pyh_payperiod = @payperiod) and
		stp_loadstatus = 'LD' and
     		isnull(stp_lgh_mileage, 0) >0), 0) 'Loaded Miles',

	IsNull((select sum(s2.stp_lgh_mileage) 
 		from stops s2 where lgh_number IN(select lgh_number 
     		from paydetail p3 
     		where p1.asgn_id = p3.asgn_id and 
     		p3.pyh_payperiod = @payperiod) and
     		stp_loadstatus = 'MT' AND
     		isnull(stp_lgh_mileage, 0) >0),0) 'Empty Miles'
from 	paydetail p1, 
	--legheader, 
	paytype,
	#stltemp
where 	--p1.lgh_number = legheader.lgh_number and 
	p1.pyh_payperiod = @payperiod and
	p1.pyt_itemcode = paytype.pyt_itemcode and 	
	@asgntype IN ('ALL', p1.asgn_type) and
	@asgnID IN ('ALL', p1.asgn_id) and
	p1.asgn_id = #stltemp.asgn_id
	

group by  	p1.asgn_type, 
		p1.asgn_id, 	
		p1.pyh_payperiod,
		p1.pyt_itemcode,
		paytype.pyt_description,	
		#stltemp.totalmileagepay

order by asgn_type, p1.asgn_id, paytype.pyt_description

drop table #stltemp

GO
GRANT EXECUTE ON  [dbo].[d_stl_summary_payperiod_brpt] TO [public]
GO
