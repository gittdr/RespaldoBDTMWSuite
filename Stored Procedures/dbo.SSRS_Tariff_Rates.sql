SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- exec SSRS_Tariff_Rates '2009-01-01','STRSEG01'

create proc [dbo].[SSRS_Tariff_Rates]
	(
		@Date datetime,
		@CompanyList as varchar(8000)
	)

as

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON


select  @CompanyList = ',' + @CompanyList + ','

select * 

from 
(
select	
	th.tar_number 'Primary Tariff No',
	th.tar_description 'Tariff Description',
	billCmp.cmp_name 'Tariff Key BillTo Name',
	dbo.TMWSSRS_fnc_KeyString(trk_number) 'Tarrif Key',
	case when trow.trc_matchvalue = 'UNKNOWN' then
		case when trow.trc_rangevalue = 2147483647.00 then  
			'MAX'
		else
			rtrim(ltrim(str(trow.trc_rangevalue)))
		end
	else
		case rb.name 
			when 'Origin City' then
				(select RowCity.cty_name + ', ' + RowCity.cty_state 
				 from city RowCity where RowCity.cty_code = trow.trc_matchvalue)
			when 'Dest. City' then 
				(select RowCity.cty_name + ', ' + RowCity.cty_state 
				 from city RowCity where RowCity.cty_code = trow.trc_matchvalue)
			when 'Dest. Company' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = trow.trc_matchvalue)
			when 'Bill To' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = trow.trc_matchvalue)
			when 'Origin Company' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = trow.trc_matchvalue)
			when 'Stop Company' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = trow.trc_matchvalue)
		else
			trow.trc_matchvalue		
		end
	end 'Row',
	case when tcol.trc_matchvalue = 'UNKNOWN' then
		case when tcol.trc_rangevalue = 2147483647.00 then  
			'MAX'
		else
			rtrim(ltrim(str(tcol.trc_rangevalue)))
		end
	else
		case cb.name 
			when 'Dest. City' then 
				(select ColCity.cty_name + ', ' + ColCity.cty_state 
				 from city ColCity where ColCity.cty_code = tCol.trc_matchvalue)
			when 'Origin City' then 
				(select ColCity.cty_name + ', ' + ColCity.cty_state 
				 from city ColCity where ColCity.cty_code = tCol.trc_matchvalue)
			when 'Dest. Company' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = tcol.trc_matchvalue)
			when 'Bill To' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = tcol.trc_matchvalue)
			when 'Origin Company' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = tcol.trc_matchvalue)
			when 'Stop Company' then (Select cmp_name + ' ' + cty_nmstct from company where cmp_id = tcol.trc_matchvalue)

		else
			isnull(tcol.trc_matchvalue,'')
		end
	end 'Col',

	trk_startdate 'Effective Date',
	case when th.tar_rate = 0 then
		case when cb.name = 'Not Used' then
			(select top 1 tra_rate from tariffrate trate where trate.trc_number_row = trow.trc_number)
		else
			(select top 1 tra_rate from tariffrate trate where trate.trc_number_row = trow.trc_number and trate.trc_number_col = tcol.trc_number)
		end 
	else
		th.tar_rate
	end as 'Rate',

	trk_enddate 'Expire Date',
	cb.name 'Column Name',
	rb.name 'Row Name',

--	(select top 1 acctarh.tar_number from tariffaccessorial ta
--		inner join tariffkey accTar on accTar.trk_number =  ta.trk_number
--		inner join tariffheader accTarH on accTarH.tar_number = accTar.tar_number
--	 where ta.tar_number = th.tar_number and acctarh.cht_itemcode in ('FSCP','FSCM','FSCF','FSCMIL','FSCREV','FSCTON','FUELFL')
--	 
--	) 'FSC Tariff#',
--	(select top 1 acctarh.tar_description from tariffaccessorial ta
--		inner join tariffkey accTar on accTar.trk_number =  ta.trk_number
--		inner join tariffheader accTarH on accTarH.tar_number = accTar.tar_number
--	 where ta.tar_number = th.tar_number and acctarh.cht_itemcode in ('FSCP','FSCM','FSCF','FSCMIL','FSCREV','FSCTON','FUELFL')
--	)  'FSC Tariff Desc',
	dbo.TMWSSRS_fcn_AttachedTariff_comma_sep(th.tar_number) 'Attached Tarrifs',

	case when th.tar_minquantity > 0 then
		'Yes'
	else
		'No'
	end as 'Minimum Quantity',
	case when tk.trk_revtype4 = 'UNK' then
		''
	else
		tk.trk_revtype4 
	end 'Haul Type',
	tk.trk_description 'Product Type',
	(select top 1 not_text from notes 
	 where ntb_table = 'Rate' and nre_tablekey = th.tar_number
	 order by last_updatedatetime desc) 'Notes',
	trow.trc_sequence [Row Sequence],
	tcol.trc_sequence [Col Sequence],
	ct.cht_description

from tariffheader th
	inner join chargetype ct on ct.cht_itemcode = th.cht_itemcode
	left join  labelfile rb on rb.abbr = th.tar_rowbasis and rb.labeldefinition = 'TariffBasisInv'
	left join  labelfile cb on cb.abbr = th.tar_colbasis and cb.labeldefinition = 'TariffBasisInv'
	inner join tariffkey tk on tk.tar_number = th.tar_number
	left join  tariffrowcolumn trow on trow.tar_number = th.tar_number and trow.trc_rowcolumn = 'R' 
	left join  tariffrowcolumn tcol on tcol.tar_number = th.tar_number and tcol.trc_rowcolumn = 'C'
	left join  city RowCity  on RowCity.cty_code = trow.trc_matchvalue and rb.name in ('Dest. City','Origin City')
	left join  city ColCity on ColCity.cty_code = tcol.trc_number
	left join  company billCmp on billCmp.cmp_id = tk.trk_billto
	left join  commodity cmd on cmd.cmd_code = tk.cmd_code

where 
	trk_primary = 'Y'
	-- and [Lookup Rate]  0
	and trk_enddate > @Date
	and
		((charindex((',' + rtrim(tk.trk_billto) + ','), @CompanyList, 1) > 0)
			 or 
		(@CompanyList = ',,'))


) rs
where [Rate] <> 0
order by [Primary Tariff No], [Tariff Description], [Col Sequence], [Row Sequence]


GO
