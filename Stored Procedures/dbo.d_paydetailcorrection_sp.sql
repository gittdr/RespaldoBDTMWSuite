SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



create procedure [dbo].[d_paydetailcorrection_sp]
		(@vi_ord_hdrnumber	int, @defaultMOAsgnType varchar(6), @defaultMOAsgnID varchar(8))
as

/* d_PayDetailCorrection_sp
 	This proc replaces the embedded SQL in the DataWindow d_PayDetailCorrection.  The pay
	details window used to retrieve resources for only 1 move on an order.  This is changed
	to retrieve for multiple moves on an order.

	Parameters:	@vi_ord_hdrnumber		The ord_hdrnumber for which to select resources.

	Returns:	none (result set)

	Revision History:
	Date		Name			PTS		Label	Description
	-----------	---------------	-------	-------	------------------------------------------
	12/07/2002	Vern Jewett		15629	(none)	Original
   	6/16/3      	DPETE          			Provide a default list of assets for master orders
   	01/06/06	DJM			31021	Check the Asset Assignments Pay Status
	LOR	PTS# 37918	added asgn_controlling
	08/10/2007	BDH			36019	added tpr_type
	LOR	PTS# 62520	add tpr_split, tpr_split_flag
*/
Select @defaultMOAsgnID = IsNull(@defaultMOAsgnID,'UNKNOWN')
Select @defaultMOAsgnType = IsNull(@defaultMOAsgnType,'UNK')
create table #move
		(mov_number			int	null
		,mov_total_mileage	int	null)

Create table #results (
	Asgn_type 		varchar(6) Null,
	asgn_id 		varchar(13) Null,
	lgh_number 		Int null,
	asgn_date 		datetime null,
	actg_type 		varchar(6) Null,
	total_lgh_mileage 	int Null,
	total_mileage 		int Null,
	mov_number 		int null,
	asgn_number 		int null,
	ord_number 		varchar(12) null,
	pyd_status		varchar(6) null,
	asgn_controlling	char(1) null,
	tpr_type		varchar(20) null,
	tpr_split		money null,
	tpr_split_flag	char(1) null,
	tpr_number		int null
)

declare	@li_total_mileage	int
		,@ls_ord_number		char(12),
   @ordstatus varchar(6)


--Get all distinct moves used to fulfill this order..
insert into #move
		(mov_number)
  select distinct mov_number
  from	stops
  where	ord_hdrnumber = @vi_ord_hdrnumber


--Get the total mileage on all moves..
select	@li_total_mileage = sum(stp_lgh_mileage)
  from	#move m
		,stops s
  where	s.mov_number = m.mov_number

--Get ord_number..
select	@ls_ord_number = ord_number, @ordstatus = ord_status
  from	orderheader
  where	ord_hdrnumber = @vi_ord_hdrnumber


--Result set..
-- For regulare trips where an asset assignment has been made
If @ordstatus <> 'MST' or Not exists (Select asgn_id From assetassignment aa, #move mm Where aa.mov_number = aa.mov_number) 
begin
 Insert into #results
  select	aa.asgn_type
		,aa.asgn_id
		,aa.lgh_number
		,aa.asgn_date
		,aa.actg_type
		,sum(s.stp_lgh_mileage) as total_lgh_mileage
		,@li_total_mileage as total_mileage
		,aa.mov_number
		,aa.asgn_number
		,@ls_ord_number as ord_number
		,aa.pyd_status,
		aa.asgn_controlling,	
		'',
		0,
		'',
		0
  from	#move m
		,assetassignment aa
		,stops s
  where	aa.mov_number = m.mov_number
	and	aa.actg_type <> 'N'
	and	s.lgh_number = aa.lgh_number
  group by aa.asgn_type
		,aa.asgn_id
		,aa.lgh_number
		,aa.asgn_date
		,aa.actg_type
		,aa.mov_number
		,aa.asgn_number
		,aa.pyd_status,
		aa.asgn_controlling

	-- 36019.  Third parties go to the thirdpartyassignment table. 
 	Insert into #results
	  select	'TPR' --tp.tpr_type
			,tp.tpr_id
			,tp.lgh_number
			,''
			,''
			,''--sum(s.stp_lgh_mileage) as total_lgh_mileage
			,''--@li_total_mileage as total_mileage
			,tp.mov_number
			,tp.tpr_number
			,@ls_ord_number as ord_number
			,tp.pyd_status
			,''
			,tp.tpr_type
			,tpr_split
			,tpr_split_flag
			,tpr_number
	  from	#move m
			,thirdpartyassignment tp
			,stops s
	  where	tp.mov_number = m.mov_number		
		and	s.lgh_number = tp.lgh_number
		and 	tp.tpa_status <> 'DEL'
		and 	tp.ord_number in (select ord_number from orderheader where ord_hdrnumber = @vi_ord_hdrnumber)
	  group by tp.tpr_type,
			tp.tpr_id
			,tp.lgh_number
			,tp.mov_number
			,tp.tpr_number
			,tp.pyd_status
			,tpr_split
			,tpr_split_flag
			,tpr_number
		-- 36019 end
	end
Else

  Begin
  Insert Into #results
  select	asgn_type = 'DRV',
		asgn_id = Case @defaultMOAsgnType When 'DRV' Then @defaultMOAsgnID Else 'UNKNOWN' End,
		lgh_number,
		asgn_date = '1-1-1950'
		,'P'
		,sum(s.stp_lgh_mileage) as total_lgh_mileage
		,@li_total_mileage as total_mileage
		,m.mov_number
		,0
		,@ls_ord_number as ord_number
		,'' as pyd_status,
		'Y'
		,'' 
		,0
		,''
		,0
  from	#move m
		,stops s
  Where s.mov_number = m.mov_number
  group by lgh_number, m.mov_number

  Insert Into #results
  select	asgn_type = 'TRC',
		asgn_id = Case @defaultMOAsgnType When 'TRC' Then @defaultMOAsgnID Else 'UNKNOWN' End,
		lgh_number,
		asgn_date = '1-1-1950'
		,actg_type = 'P'
		,sum(s.stp_lgh_mileage) as total_lgh_mileage
		,@li_total_mileage as total_mileage
		,m.mov_number
		,0
		,@ls_ord_number as ord_number
		,'' as pyd_status,
		'Y' 
		,''  
		,0
		,''
		,0
  from	#move m
		,stops s
  Where s.mov_number = m.mov_number
  group by lgh_number, m.mov_number

  Insert Into #results
  select	asgn_type = 'CAR',
		asgn_id = Case @defaultMOAsgnType When 'CAR' Then @defaultMOAsgnID Else 'UNKNOWN' End,
		lgh_number,
		asgn_date = '1-1-1950'
		,actg_type = 'P'
		,sum(s.stp_lgh_mileage) as total_lgh_mileage
		,@li_total_mileage as total_mileage
		,m.mov_number
		,0
		,@ls_ord_number as ord_number
  		,'' as pyd_status,
		'Y' 
		,'' 
		,0
		,'' 
		,0
from	#move m
		,stops s
  Where s.mov_number = m.mov_number
  group by lgh_number, m.mov_number

  Insert Into #results
  select	asgn_type = 'TRL',
		asgn_id = Case @defaultMOAsgnType When 'TRL' Then @defaultMOAsgnID Else 'UNKNOWN' End,
		lgh_number,
		asgn_date = '1-1-1950'
		,'P'
		,sum(s.stp_lgh_mileage) as total_lgh_mileage
		,@li_total_mileage as total_mileage
		,m.mov_number
		,0
		,@ls_ord_number as ord_number
 		,'' as pyd_status,
		'Y' 
		,''  
		,0
		,''
		,0
 from	#move m
		,stops s
  Where s.mov_number = m.mov_number
  group by lgh_number, m.mov_number
 End

Select *, 
		0, 
		0
from #results 
Order by (Case Asgn_id when 'UNKNOWN' Then 9 else 0 End),
		asgn_type
		
		
drop table #move
drop table #results
GO
GRANT EXECUTE ON  [dbo].[d_paydetailcorrection_sp] TO [public]
GO
