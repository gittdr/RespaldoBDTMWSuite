SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[vSSRSRB_BrokerRevenueAndPay]

as
/**
 *
 * NAME:
 * dbo.vSSRSRB_BrokerRevenueAndPay
 *
 * TYPE:
 *View
 *
 * DESCRIPTION:
 * margin report
 
 *
**************************************************************************

Sample call


select * from vSSRSRB_BrokerRevenueAndPay


**************************************************************************
 * RETURNS:
 * Recordset
 * RESULT SETS:
 * Margin report
 *
 * PARAMETERS:
 * n/a
 *
 * REFERENCES: 
 *
 * REVISION HISTORY:
 *
 * 3/20/2014 JR created new SSRS view based on the original by Brian O'Sickey
 **/
select 
	rs.*,
	[Order Margin] = [Order Total] - ([Linehaul Pay] + [Acc Pay]),
	[Order Margin with Pay Debits] = [Order Total] - ([Linehaul Pay] + [Acc Pay] + [Pay Debits]),
	[Margin] = [Invoice Total] - ([Linehaul Pay] + [Acc Pay]),
	[FSC Margin] = [FSC Charge] - [FSC Pay],
	[Detention Margin] = [Detention Charge] - [Detention Pay],
	[Lumper Margin] = [Lumper Charge] - [Lumper Pay],
	[TONU Margin] = [TONU Charge] - [TONU Pay],
	[Misc Acc Rev] = [Acc Rev] - [FSC Charge] - [Detention Charge] - [Lumper Charge] - [TONU Charge],
	[Misc Acc Pay] = [Acc Pay] - [FSC Pay] - [Detention Pay] - [Lumper Pay] - [TONU Pay],
	isnull((select car_name from carrier  with(NOLOCK)  where car_id = [Carrier Id]),'') as 'Carrier Name'
	
 from 

	(

	select 

		o.ord_hdrnumber as [Order Header Number],
		o.ord_number as [Order Number],
		convert(varchar(10),ord_startdate,101) as 'Ship Date Only',

		ord_startdate 'Ship Date',
		ord_billto as 'Bill To ID',
		bc.cmp_name as 'Bill To Name',
		ord_revtype1 as 'Rev Type1',
		rt1.name 'Rev Type1 Name',
		ord_revtype2 as 'Rev Type2',
		rt2.name 'Rev Type2 Name',
		ord_revtype3 as 'Rev Type3',
		rt3.name 'Rev Type3 Name',
		ord_revtype4 as 'Rev Type4',
		rt4.name 'Rev Type4 Name',	
		
		ord_totalcharge 'Order Total',
		

		--isnull(ivh_totalcharge,0) 'Invoice Total',

		isnull((select sum(ivh_totalcharge) from invoiceheader ih  with(NOLOCK) 
				where ih.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'Invoice Total',

		
		isnull((select sum(pyd_amount) from paydetail pd with(NOLOCK) 
				where pd.pyt_itemcode <> 'ADV' and pd.ord_hdrnumber = o.ord_hdrnumber
			),0) as 'Total Pay',

		ord_charge 'Order Linehaul',
		isnull((select sum(ivd_charge) from invoicedetail id with(NOLOCK) 
				inner join chargetype ct on ct.cht_itemcode = id.cht_itemcode and cht_basis = 'SHP'
				and id.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'Invoice LineLH',
		isnull((select sum(ivd_charge) from invoicedetail id  with(NOLOCK) 
				inner join chargetype ct on ct.cht_itemcode = id.cht_itemcode and cht_basis = 'ACC'
				and id.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'Acc Rev',
		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
			inner join paytype pt on pt.pyt_itemcode = pd.pyt_itemcode and pyt_basis = 'LGH'
			and pd.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'Linehaul Pay',
		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
			inner join paytype pt on pt.pyt_itemcode = pd.pyt_itemcode and pyt_basis <> 'LGH'
			and pd.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'Acc Pay',
		case when
			(select count(0) from (select distinct lgh_number 
						  from stops  with(NOLOCK) 
						  where ord_hdrnumber = 608) rs
			) > 1 then
				'Split Trip'
		else
			''
		end as 'Split Flag',
		---------------------------
		-- Fuel Charges & Payments
		---------------------------
		isnull((select sum(ivd_charge) from invoicedetail id  with(NOLOCK) 
				inner join chargetype ct on ct.cht_itemcode = id.cht_itemcode 
					and CharIndex('FUEL', cht_description)>0
					and id.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'FSC Charge',
		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
				inner join paytype pt on pt.pyt_itemcode = pd.pyt_itemcode 
					and CharIndex('FUEL', upper(pyt_description))>0
					and pt.pyt_itemcode <> 'FUELAD'
					and pd.ord_hdrnumber = o.ord_hdrnumber
			),0) as 'FSC Pay',
		------------------------------- 
		-- Detention Charges & Payments select * from paytype
		-------------------------------
		isnull((select sum(ivd_charge) from invoicedetail id  with(NOLOCK) 
				inner join chargetype ct on ct.cht_itemcode = id.cht_itemcode 
					and CharIndex('DETENTION', cht_description)>0
					and id.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'Detention Charge',
		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
				inner join paytype pt on pt.pyt_itemcode = pd.pyt_itemcode 
					and CharIndex('DETENTION', upper(pyt_description))>0
					and pd.ord_hdrnumber = o.ord_hdrnumber
			),0) as 'Detention Pay',
		---------------------------
		-- Lumper Charges & Payments
		---------------------------
		isnull((select sum(ivd_charge) from invoicedetail id  with(NOLOCK) 
				inner join chargetype ct on ct.cht_itemcode = id.cht_itemcode 
					and CharIndex('LUMPER', cht_description)>0
					and id.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'Lumper Charge',
		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
				inner join paytype pt on pt.pyt_itemcode = pd.pyt_itemcode 
					and CharIndex('LUMPER', upper(pyt_description))>0
					and pd.ord_hdrnumber = o.ord_hdrnumber
			),0) as 'Lumper Pay',
		--------------------------- 
		-- TONU Charges & Payments
		---------------------------
		isnull((select sum(ivd_charge) from invoicedetail id  with(NOLOCK) 
				where id.cht_itemcode = 'TRKORD' and id.ord_hdrnumber = o.ord_hdrnumber
		),0) as 'TONU Charge',
		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
				where pd.pyt_itemcode = 'TRKORD' and pd.ord_hdrnumber = o.ord_hdrnumber
			),0) as 'TONU Pay',

		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
				where (	pd.pyt_itemcode = 'ADVFEE'
						or pd.pyt_itemcode = 'FUELAD'
						or pd.pyt_itemcode = 'QP1-3'
						or pd.pyt_itemcode = 'QP7-10'
						or pd.pyt_itemcode = 'SERVIC')
						and pd.ord_hdrnumber = o.ord_hdrnumber
			),0) as 'Pay Debits',

		
		isnull((select top 1 asgn_id from paydetail pd  with(NOLOCK) 
			where  pd.asgn_type = 'CAR'
			and pd.ord_hdrnumber = o.ord_hdrnumber),'')  as 'Carrier ID',

		(select max(updated_dt) from expedite_audit with(NOLOCK)  where charindex('-> CMP',update_note)>0
			and ord_hdrnumber = o.ord_hdrnumber) 'Order CMP Status Date',

		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
			where  pd.asgn_type = 'CAR'
			and pd.ord_hdrnumber = o.ord_hdrnumber),'')  as 'Carrier Pay',

		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
			where  pd.asgn_type not in ('TPR','CAR')
			and pd.ord_hdrnumber = o.ord_hdrnumber),'')  as 'Asset Pay',

		isnull((select sum(pyd_amount) from paydetail pd  with(NOLOCK) 
			where  pd.asgn_type = 'TPR'
			and pd.ord_hdrnumber = o.ord_hdrnumber),'')  as '3rd Party Pay',

		o.ord_consignee as 'Consignee ID',
		o.ord_shipper as 'Shipper ID',
		cc.cmp_name as 'Consignee Name',
		sc.cmp_name as 'Shipper Name'




	from orderheader o  with(NOLOCK) 
--		left join invoiceheader ih on ih.ord_hdrnumber = o.ord_hdrnumber
		join company bc  with(NOLOCK) on bc.cmp_id = o.ord_billto 
		join company cc  with(NOLOCK) on cc.cmp_id = o.ord_consignee
 		join company sc  with(NOLOCK) on sc.cmp_id = o.ord_shipper
		left join labelfile rt1  with(NOLOCK) on rt1.abbr = o.ord_revtype1 and rt1.labeldefinition = 'RevType1'
		left join labelfile rt2  with(NOLOCK) on rt2.abbr = o.ord_revtype2 and rt2.labeldefinition = 'RevType2'
		left join labelfile rt3  with(NOLOCK) on rt3.abbr = o.ord_revtype3 and rt3.labeldefinition = 'RevType3'
		left join labelfile rt4  with(NOLOCK) on rt4.abbr = o.ord_revtype4 and rt4.labeldefinition = 'RevType4'

) rs
GO
GRANT SELECT ON  [dbo].[vSSRSRB_BrokerRevenueAndPay] TO [public]
GO
