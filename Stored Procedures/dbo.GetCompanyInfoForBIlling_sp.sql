SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetCompanyInfoForBIlling_sp] (
 @ps_billto varchar(8), @inibillcmpmiscfielddisplay varchar(6)
,@ps_shipper varchar(8),@inishipcmpmiscfielddisplay varchar(6)
,@ps_consignee varchar(8), @iniconscmpmiscfielddisplay varchar(6)
) 
as

/*

PTS 51432 if one company has blank zip on company with zip on city  and another company has zip on company but blank zip on city
    the zip on the first company is lost affecting rating.
PTS62072 add pophubmiles and avgfuelpricedate
PTS62660 add cmp_billing_rating_engine
*/
set nocount on

declare @companydata table(
cmprole char(1) NUll
,cmp_id varchar(8) null
,cmp_name varchar(26) null
,cmp_address1 varchar(100) null
,cmp_address2 varchar(100) null
,cmp_zip varchar(10) null
,cty_nmstct varchar(30) null
,miscvalue varchar(254) null
,cmp_geoloc varchar(50) null
,cmp_defaultbillto varchar(8) null
,cmp_transfertype varchar(6) null
,cmp_overrideapplyhighestrate char(1) null
,cmp_contact  varchar(30) null
,cmp_blended_min_qty decimal(9,4) null
,cmp_minchargeoption varchar(30) null
,cmp_mailto_name varchar(30) null
,cmp_rbd_flatrateoption varchar(10) null
,cmp_minlhadj money null
,cmp_rbd_highrateoption varchar(10) null
,cmp_max_dunnage int null
,cmp_mileagetable varchar(2) null
,cmp_invoicetype varchar(6) null
,cmp_taxid varchar(15) null
,cmp_min_charge money null
,cmp_mastercompany varchar(8) null
,cmp_splitbillonrefnbr char(1) null
,cmp_currency varchar(6) null
,cmp_country varchar(50)null
,cmp_inv_toll_detail char(1) null
,companyaddrcount int null
,cmp_state char(6) null
,cmp_altid  varchar(25) null
,cmp_city int null
,cmp_reftype_unique varchar(6) null
,cmp_billto char(1) null
,cmp_active char(1) null  
,cmp_tollmethod char(6)	null
,cmp_pophubmilesflag varchar(3) null
,cmp_avgfuelpricedateoverride char(1)null
,cmp_billing_rating_engine varchar(6) null

)


  insert into @companydata
  select roll = 'S'
  , cmp_id
  ,cmp_name = isnull(substring(cmp_name,1,26),'Name NOF')
  ,cmp_address1 = isnull(cmp_address1,'Street NOF')
  ,cmp_address2
  ,cmp_zip = rtrim(isnull(cmp_zip,''))
  ,cty_nmstct = company.cty_nmstct
  ,miscvalue = Case @inishipcmpmiscfielddisplay when '2' then cmp_misc2 when '3' then cmp_misc3 when '4' then cmp_misc4 else  company.cmp_misc1 end 
  ,cmp_geoloc
  ,cmp_defaultbillto
  ,cmp_transfertype
  ,cmp_overrideapplyhighestrate 
  ,cmp_contact = isnull(cmp_contact,'')
  ,isnull(cmp_blended_min_qty ,0)
  ,cmp_minchargeoption = isnull(cmp_minchargeoption ,'')
  ,cmp_mailto_name = isnull(cmp_mailto_name,'')
  ,cmp_rbd_flatrateoption = isnull(cmp_rbd_flatrateoption,'N')
  ,cmp_minlhadj = isnull(cmp_minlhadj,0.0)
  ,cmp_rbd_highrateoption = isNUll(cmp_rbd_highrateoption,'')
  ,cmp_max_dunnage
  ,cmp_mileagetable
  ,cmp_invoicetype = isnull(cmp_invoicetype,'INV')
  ,cmp_taxid
  ,cmp_min_charge
  ,cmp_mastercompany
  ,cmp_splitbillonrefnbr = IsNull(cmp_splitbillonrefnbr,'N')
  ,cmp_currency
  ,cmp_country
  ,cmp_inv_toll_detail
  ,0
  ,cmp_state
  ,cmp_altid  
  ,cmp_city
  ,cmp_reftype_unique
  ,cmp_billto
  ,cmp_active 
  ,cmp_tollmethod
  ,isnull(cmp_pophubmilesflag,'I') cmp_pophubmilesflag 
  ,cmp_avgfuelpricedateoverride
  ,cmp_billing_rating_engine   -- used for bill to only

  from company where cmp_id = @ps_shipper

insert into @companydata
  select
   roll = 'C' 
   ,cmp_id
  ,cmp_name = isnull(substring(cmp_name,1,26),'Name NOF')
  ,cmp_address1 = isnull(cmp_address1,'Street NOF')
  ,cmp_address2
  ,cmp_zip = rtrim(isnull(cmp_zip,''))
  ,cty_nmstct = company.cty_nmstct
  ,miscvalue = Case @iniconscmpmiscfielddisplay when '2' then cmp_misc2 when '3' then cmp_misc3 when '4' then cmp_misc4 else  company.cmp_misc1 end 
  ,cmp_geoloc
  ,cmp_defaultbillto
  ,cmp_transfertype
  ,cmp_overrideapplyhighestrate 
  ,cmp_contact = isnull(cmp_contact,'')
  ,isnull(cmp_blended_min_qty ,0)
  ,cmp_minchargeoption = isnull(cmp_minchargeoption ,'')
  ,cmp_mailto_name = isnull(cmp_mailto_name,'')
  ,cmp_rbd_flatrateoption = isnull(cmp_rbd_flatrateoption,'N')
  ,cmp_minlhadj = isnull(cmp_minlhadj,0.0)
  ,cmp_rbd_highrateoption = isNUll(cmp_rbd_highrateoption,'')
  ,cmp_max_dunnage
  ,cmp_mileagetable
  ,cmp_invoicetype = isnull(cmp_invoicetype,'INV')
  ,cmp_taxid
  ,cmp_min_charge
  ,cmp_mastercompany
  ,cmp_splitbillonrefnbr = IsNull(cmp_splitbillonrefnbr,'N')
  ,cmp_currency
  ,cmp_country
  ,cmp_inv_toll_detail
  ,0
  ,cmp_state
  ,cmp_altid 
  ,cmp_city
  ,cmp_reftype_unique
  ,cmp_billto
  ,cmp_active 
  ,cmp_tollmethod
  ,isnull(cmp_pophubmilesflag,'I') cmp_pophubmilesflag 
  ,cmp_avgfuelpricedateoverride
  ,cmp_billing_rating_engine  -- used for bill to only
  from company where cmp_id  = @ps_consignee

insert into @companydata
  select 
  roll = 'B'
  , cmp_id
  ,cmp_name = isnull(substring(cmp_name,1,26),'Name NOF')
  ,cmp_address1 = isnull(cmp_address1,'Street NOF')
  ,cmp_address2
  ,cmp_zip = rtrim(isnull(cmp_zip,''))
  ,cty_nmstct = company.cty_nmstct
  ,miscvalue = Case @inibillcmpmiscfielddisplay when '2' then cmp_misc2 when '3' then cmp_misc3 when '4' then cmp_misc4 else  company.cmp_misc1 end 
  ,cmp_geoloc
  ,cmp_defaultbillto
  ,cmp_transfertype
  ,cmp_overrideapplyhighestrate 
  ,cmp_contact = isnull(cmp_contact,'')
  ,isnull(cmp_blended_min_qty,0) 
  ,cmp_minchargeoption = isnull(cmp_minchargeoption ,'')
  ,cmp_mailto_name = isnull(cmp_mailto_name,'')
  ,cmp_rbd_flatrateoption = isnull(cmp_rbd_flatrateoption,'N')
  ,cmp_minlhadj = isnull(cmp_minlhadj,0.0)
  ,cmp_rbd_highrateoption = isNUll(cmp_rbd_highrateoption,'')
  ,cmp_max_dunnage
  ,cmp_mileagetable
  ,cmp_invoicetype = isnull(cmp_invoicetype,'INV')
  ,cmp_taxid
  ,cmp_min_charge
  ,cmp_mastercompany
  ,cmp_splitbillonrefnbr = IsNull(cmp_splitbillonrefnbr,'N')
  ,cmp_currency
  ,cmp_country
  ,cmp_inv_toll_detail =  ISNULL(cmp_inv_toll_detail, 'N')
  ,(select count(*) from companyaddress ca where ca.cmp_id = @ps_billto and isnull(car_retired,'N') = 'N')
  ,cmp_state
  ,cmp_altid 
  ,cmp_city
  ,cmp_reftype_unique
  ,cmp_billto
  ,cmp_active 
  ,cmp_tollmethod
  ,isnull(cmp_pophubmilesflag,'I') cmp_pophubmilesflag 
  ,cmp_avgfuelpricedateoverride
  , isnull(cmp_billing_rating_engine,'TMW') cmp_billing_rating_engine 
  
   
  from company where cmp_id  = @ps_billto

if exists (select 1 from @companydata where cmp_zip = '')
  update @companydata
  set cmp_zip = isnull(cty_zip,'')
  from @companydata cmp
  join city on cmp.cty_nmstct = city.cty_nmstct
  where cty_zip is not null
  and cmp.cmp_zip = ''

if exists (select 1 from @companydata where cmp_zip = '')
  update @companydata
  set cmp_zip = 'Zip NOF'
  where cmp_zip = ''

 select cmprole
,cmp_id
,cmp_name
,cmp_address1
,cmp_address2
,cmp_zip = rtrim(isnull(cmp_zip,''))
,cty_nmstct
,miscvalue = isnull(miscvalue,'')
,cmp_geoloc = isnull(cmp_geoloc,'')
,cmp_defaultbillto
,cmp_transfertype
,cmp_overrideapplyhighestrate
,cmp_contact
,cmp_blended_min_qty
,cmp_minchargeoption
,cmp_mailto_name 
,cmp_rbd_flatrateoption 
,cmp_minlhadj
,cmp_rbd_highrateoption 
,cmp_max_dunnage 
,cmp_mileagetable
,cmp_invoicetype 
,cmp_taxid 
,cmp_min_charge
,cmp_mastercompany
,cmp_splitbillonrefnbr
,cmp_currency 
,cmp_country
,cmp_inv_toll_detail
,companyaddrcount
,cmp_state
,cmp_altid 
,cmp_city
,cmp_reftype_unique
,cmp_billto
,cmp_active 
,cmp_tollmethod
,cmp_pophubmilesflag 
,cmp_avgfuelpricedateoverride
,cmp_billing_rating_engine 

from @companydata
order by cmprole  -- row 1 of return set is bill to, row 2 is consignee , row 3 is shipper

GO
GRANT EXECUTE ON  [dbo].[GetCompanyInfoForBIlling_sp] TO [public]
GO
