SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--invoicedetail.cht_itemcode,   
--         invoicedetail.ivd_description,   
--         invoicedetail.cmp_id,   
--         company.cmp_name,   
--         company.cty_nmstct,   
--         invoicedetail.ivd_quantity,   
--         invoicedetail.ivd_rate,   
--         invoicedetail.ivd_charge,   
--         invoicedetail.ivd_billto,   
--         invoicedetail.ivh_hdrnumber,   
--         invoicedetail.ivd_number,   
--         invoicedetail.ord_hdrnumber,   
--         invoicedetail.ivd_glnum,   
--         invoicedetail.ivd_type,   
--         invoicedetail.ivd_unit,   
--         invoicedetail.cur_code,   
--         invoicedetail.ivd_currencydate,   
--         invoicedetail.ivd_rateunit,   
--         invoicedetail.ivd_sequence,   
--         invoicedetail.ivd_invoicestatus,   
--         invoicedetail.ivd_refnum,   
--         invoicedetail.cmd_code,   
--         invoicedetail.ivd_reftype,   
--         invoicedetail.ivd_sign,   
--        sp_help chargetype.cht_basis,
--         invoicedetail.cht_basisunit,   
--         sp_help commodity.cmd_taxtable1,   
--         commodity.cmd_taxtable2,   
--         commodity.cmd_taxtable3,   
--         commodity.cmd_taxtable4,   
--         invoicedetail.ivd_taxable1,   
--         invoicedetail.ivd_taxable2,   
--         invoicedetail.ivd_taxable3,   
--         invoicedetail.ivd_taxable4,
--         invoicedetail.ivd_fromord,
--         invoicedetail.tar_number,
--         invoicedetail.tar_tariffnumber,
--        sp_help invoicedetail.tar_tariffitem,
--         invoicedetail.ivd_remark,
--         invoicedetail.stp_number,
--         invoicedetail.cht_class,
--         chargetype.cht_rateprotect,
--         chargetype.cht_primary,
--         invoicedetail.cht_rollintolh,
--         invoicedetail.cht_lh_rev,
--         invoicedetail.cht_lh_min,
--         invoicedetail.cht_lh_stl,
--         invoicedetail.cht_lh_rpt,
--         invoicedetail.ivd_paylgh_number,
--         invoicedetail.ivd_tariff_type,
--         invoicedetail.ivd_taxid,
--         chargetype.gp_tax,
--         invoicedetail.ivd_charge_type, 
--         invoicedetail.cht_lh_prn,
--	invoicedetail.ivd_revtype1,
--	'RevType1' revtype1_t,
--	'ChrgTypeClass' chrgtypeclass_t,
--	invoicedetail.ivd_wgt,
--	invoicedetail.ivd_wgtunit,
--	invoicedetail.ivd_count,
--	invoicedetail.ivd_countunit,
--	invoicedetail.ivd_volume,
--	invoicedetail.ivd_volunit,
--	invoicedetail.ivd_distance,
--	invoicedetail.ivd_distunit,
--	IsNull(ivh_invoicenumber,'') ivh_invoicenumber ,
--	IsNull(ivh_definition,'') ivh_definition ,
--	c_approved_protect = 0,
--	IsNull(ivd_hide, 'N' ) ivd_hide,
--	IsNull(usr_supervisor, 'N') usr_supervisor,
--	invoicedetail.ivd_payrevenue,
--    isnull(invoicedetail.fgt_number,0) invoicedetail_fgt_number


CREATE procedure [dbo].[sp_prueba_jr]
@mov integer
as
--begin
create table #conceptosfactura(
TT_cht_itemcode varchar(6),   
         TT_ivd_description varchar(60),   
         TT_cmp_id varchar(8),   
         TT_cmp_name varchar(100),   
         TT_cty_nmstct varchar(25),   
         TT_ivd_quantity float,   
         TT_ivd_rate money,   
         TT_ivd_charge money,   
         TT_ivd_billto varchar(8),   
         TT_ivh_hdrnumber int,   
         TT_ivd_number int,   
         TT_ord_hdrnumber int,   
         TT_ivd_glnum char(32),   
         TT_ivd_type varchar(6),   
         TT_ivd_unit varchar(6),   
         TT_cur_code varchar(6),   
         TT_ivd_currencydate datetime,   
         TT_ivd_rateunit varchar(6),   
         TT_ivd_sequence int,   
         TT_ivd_invoicestatus varchar(6),   
         TT_ivd_refnum varchar(30),   
         TT_cmd_code varchar(8),   
         TT_ivd_reftype varchar(6),   
         TT_ivd_sign smallint,   
         TT_cht_basis varchar(6),
         TT_cht_basisunit varchar(6),   
         TT_cmd_taxtable1 char(1),   
         TT_cmd_taxtable2 char(1),   
         TT_cmd_taxtable3 char(1),   
         TT_cmd_taxtable4 char(1),   
         TT_ivd_taxable1 char(1),   
         TT_ivd_taxable2 char(1),   
         TT_ivd_taxable3 char(1),   
         TT_ivd_taxable4 char(1),
         TT_ivd_fromord char(1),
         TT_tar_number int,
         TT_tar_tariffnumber varchar(12),
         TT_tar_tariffitem varchar(12),
         TT_ivd_remark varchar(255),
         TT_stp_number int,
         TT_cht_class varchar(6),
         TT_cht_rateprotect char(1),
         TT_cht_primary char(1),
         TT_cht_rollintolh int,
         TT_cht_lh_rev char(1),
         TT_cht_lh_min char(1),
         TT_cht_lh_stl char(1),
         TT_cht_lh_rpt char(1),
         TT_ivd_paylgh_number int,
         TT_ivd_tariff_type char(1),
         TT_ivd_taxid varchar(15),
         TT_gp_tax int,
         TT_ivd_charge_type smallint, 
         TT_cht_lh_prn char(1),
	TT_ivd_revtype1 varchar(6),
	TT_revtype1_t varchar(10),
	TT_chrgtypeclass_t varchar(18),
	TT_ivd_wgt float,
	TT_ivd_wgtunit varchar(6),
	TT_ivd_count dec,
	TT_ivd_countunit varchar(6),
	TT_ivd_volume float,
	TT_ivd_volunit varchar(6),
	TT_ivd_distance float,
	TT_ivd_distunit varchar(6),
	TT_ivh_invoicenumber varchar(12),
	TT_ivh_definition  varchar(6) ,
	TT_c_approved_protect int,
	TT_ivd_hide char(1),
	TT_usr_supervisor char(1),
	TT_ivd_payrevenue money,
    TT_fgt_number int)
	set nocount on 
	insert into #conceptosfactura execute dbo.d_ord_accessorials_by_mov_sp_JR   @mov = 1192309
	

 select
	replace( (STUFF(( 
	select
	'04'                                                                                        
																				+'|'+ 
	'2' --?
																				+'|'+
    ''																			
																				+'|'+
	isnull(replace(TT_cht_itemcode,'|',''),'')                                                                                             
																				+'|'+
	'1'
																				+'|'+
   'E54'
																				+'|'+
	isnull(replace(cht_description,'|',''),'')                                        
																		        +'|'+ 
	casT(isnull(cast(TT_ivd_charge as decimal(8,2)),'0')  as varchar(20))	          
																				+'|'+ 
	''                                                                                          
																		        +'|'+ 
	'ºçº'							+						 --Wildcard para despues remplazar por salto de linea
	
	case when TT_ivd_taxable1 = 'N'  then '' Else
	'041'
																				+'|'+
	'2'  --?
																				+'|'+
	'Tasa'
																				+'|'+
	'0.1600'
																				+'|'+
	casT(isnull(cast(TT_ivd_charge * 0.1600 as decimal(8,2)),'0')  as varchar(20))	
																				+'|'+
	casT(isnull(cast(TT_ivd_charge as decimal(8,2)),'0')  as varchar(20))	
	end
																				+'|'+
	'ºçº'							+					 --Wildcard para despues remplazar por salto de linea
	
	case when TT_ivd_taxable2 = 'N'  then '' Else
	'042'
																				+'|'+
	'2'  --?
																				+'|'+
	'Tasa'
																				+'|'+
	'0.04'
																				+'|'+
	casT(isnull(cast(TT_ivd_charge * 0.04 as decimal(8,2)),'0')  as varchar(20))	
																				+'|'+
	casT(isnull(cast(TT_ivd_charge as decimal(8,2)),'0')  as varchar(20))	
	end
	+'|'+
	'ºçº'
	from #conceptosfactura, chargetype
	where TT_cht_itemcode = cht_itemcode and cht_itemcode not in ('GST', 'PST')
	order by TT_ivd_number
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n' )
/*

	-- ultima parte
		
	'06'
																				+'|'+
	'002'  --?
																				+'|'+
	'Tasa'
																				+'|'+
	'0.1600'
																				+'|'+
	(cast(cast(isnull((select TT_ivd_charge*0.16  from #conceptosfactura where TT_cht_itemcode = 'GSP') ,0) as decimal(8,2)) as varchar(20))
																				+'|'+
	(cast(cast(isnull((select TT_ivd_charge  from #conceptosfactura where TT_cht_itemcode = 'GSP') ,0) as decimal(8,2)) as varchar(20))
	+'|'+
	'ºçº'

	
select
replace((STUFF((
 select
	
	'06'
																				+'|'+
	'002'  --?
																				+'|'+
	'Tasa'
																				+'|'+
	'0.1600'
																				+'|'+
	--cast(isnull(cast(select (TT_ivd_charge  * 0.1600) from #conceptosfactura where TT_cht_itemcode = 'GSP') as decimal(8,2)),'0') as varchar(20)
	(cast(cast(isnull((select TT_ivd_charge*0.16  from #conceptosfactura where TT_cht_itemcode = 'GSP') ,0) as decimal(8,2)) as varchar(20))
																				+'|'+
	(cast(cast(isnull((select TT_ivd_charge  from #conceptosfactura where TT_cht_itemcode = 'GSP') ,0) as decimal(8,2)) as varchar(20))
																				+'|'+
	'ºçº'											 --Wildcard para despues remplazar por salto de linea
	
																				+'|'+
	'07'
																				+'|'+
	'002'  --?
																				+'|'+
	'Tasa'
																				+'|'+
	'0.04'
																				+'|'+
	(cast(cast(isnull((select TT_ivd_charge*0.04  from #conceptosfactura where TT_cht_itemcode = 'PST') ,0) as decimal(8,2)) as varchar(20))
																				+'|'+
	(cast(cast(isnull((select TT_ivd_charge       from #conceptosfactura where TT_cht_itemcode = 'PST') ,0) as decimal(8,2)) as varchar(20)))
																				+'|'+
	--'ºçº'
	from #conceptosfactura, chargetype
	where TT_cht_itemcode = cht_itemcode and cht_itemcode in ('GST', 'PST')
	order by TT_ivd_number
	FOR XML PATH('')),1,0,'')
	),'ºçº' ,'\n' )
	*/
	--end
	--go

	
	--  select * from chargetype

	--  exec sp_prueba_jr @mov = 1192309
GO
