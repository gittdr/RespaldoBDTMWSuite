SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[inboundmanifest_rpt_02_sp] (@ord_number VARCHAR (12), @startdt DATETIME, @enddt DATETIME,
       @revtype1 VARCHAR(254), @revtype2 VARCHAR(254), @revtype3 VARCHAR(254), 
       @revtype4 VARCHAR(254), @origin VARCHAR(8) = 'UNKNOWN',
       @billto VARCHAR(8) = 'UNKNOWN') 
AS


SELECT @revtype1 = ',' + LTRIM(RTRIM(ISNULL(@revtype1, ''))) + ','
SELECT @revtype2 = ',' + LTRIM(RTRIM(ISNULL(@revtype2, '')))  + ','
SELECT @revtype3 = ',' + LTRIM(RTRIM(ISNULL(@revtype3, '')))  + ','
SELECT @revtype4 = ',' + LTRIM(RTRIM(ISNULL(@revtype4, '')))  + ','

IF @origin IS NULL
SELECT @origin = 'UNKNOWN'
IF LTRIM(RTRIM(@origin)) = ''
SELECT @origin = 'UNKNOWN'

IF @billto IS NULL
SELECT @billto = 'UNKNOWN'
IF LTRIM(RTRIM(@billto)) = ''
SELECT @billto = 'UNKNOWN'

DECLARE @Ord_hdrnumber Integer

SELECT @Ord_hdrnumber = Ord_hdrnumber from orderheader where ord_number = @ord_number
If @ord_number = '' or @ord_number = 'UNKNOWN' SELECT @Ord_hdrnumber = isnull(@Ord_hdrnumber,0)

SET @enddt = CONVERT(DATETIME, CONVERT(VARCHAR(12), @enddt, 101) + ' 23:59')

/* PTS 25611 - DJM - Generalinfo settings to indicated display of the Address or Zip on the Manifest
*/
Declare @Address_reftype 	VarChar(10),
	@zip_reftype		varchar(10)
select @Address_reftype = isNull(gi_string1,'')from generalinfo where gi_name = 'ManifestDisplayAddrType'
select @zip_reftype = isNull(gi_string1,'')from generalinfo where gi_name = 'ManifestDisplayZipType'


Select o.ord_number,
	o.ord_hdrnumber,
	o.mov_number,
	o.ord_fromorder,
	o.ord_terms,
	leg.lgh_tractor,
	leg.lgh_driver1,
	leg.lgh_primary_trailer,
	s.stp_arrivaldate,
	f.fgt_weight,
	f.fgt_weightunit,
	f.fgt_description,
	isNull(f.fgt_count,0) fgt_count,
	f.fgt_countunit,
	f.fgt_consignee,
	isNull((select cmp_name from company where cmp_id = f.fgt_consignee),'UNKNOWN') consignee_name,
	f.fgt_shipper,
	isNull((select cmp_name from company where cmp_id = f.fgt_shipper),'UNKNOWN') shipper_name,
	isNull(f.fgt_terms,'UNK') fgt_terms,
	(select isNull(name,'UNKNOWN')name from labelfile where labeldefinition = 'CreditTerms' and abbr = f.fgt_terms) terms_desc,
	isNull(f.fgt_count2,0) fgt_count2,
	f.fgt_count2unit,
	f.fgt_bol_status,
	isNull(f.fgt_refnum,'None') fgt_refnum,
	f.fgt_reftype,
	o.ord_revtype1,
	o.ord_revtype2,
	o.ord_revtype3,
	o.ord_revtype4,
	master.ord_refnum route_name,
	isNull((select cmp_address1 from company where cmp_id = f.fgt_shipper),'UNKNOWN') shipper_address1,
	isNull((select cmp_address2 from company where cmp_id = f.fgt_shipper),'UNKNOWN') shipper_address2,
	isNull((select city.cty_name + ', '+ cmp_state from company, city where company.cmp_city = city.cty_code and cmp_id = f.fgt_shipper),'UNKNOWN') shipper_citystate,
	isNull((select cmp_zip from company where cmp_id = f.fgt_shipper),'UNKNOWN') shipper_zip,
	isNull((select cmp_address1 from company where cmp_id = f.fgt_consignee),'UNKNOWN') consignee_address1,
	isNull((select cmp_address2 from company where cmp_id = f.fgt_consignee),'UNKNOWN') consignee_address2,
	isNull((select city.cty_name + ', '+ cmp_state from company, city where company.cmp_city = city.cty_code and cmp_id = f.fgt_consignee),'UNKNOWN') consignee_citystate,
	isNull((select cmp_zip from company where cmp_id = f.fgt_consignee),'UNKNOWN') consignee_zip,
	Case when @Address_reftype = '' then ''
		else isNull((select isNull(ref_number,'') 
			from referencenumber ref
			where ref.ref_type = @Address_reftype
				and ref.ref_table = 'orderheader'
				and ref.ref_tablekey = master.ord_hdrnumber),'')
		End display_address,
	Case when @zip_reftype = '' then ''
		else IsNull((select isNull(ref_number,'') 
			from referencenumber ref
			where ref.ref_type = @zip_reftype
				and ref.ref_table = 'orderheader'
				and ref.ref_tablekey = master.ord_hdrnumber),'')
		End display_zip,
	s.stp_sequence,
	f.fgt_leg_dest,
	f.fgt_leg_origin
  FROM orderheader o JOIN stops s ON o.ord_hdrnumber = s.ord_hdrnumber 
                     JOIN Freightdetail f ON s.stp_number = f.stp_number AND
	                  s.stp_type = 'PUP' 
                     JOIN Legheader leg ON s.lgh_number = leg.lgh_number 
                     LEFT OUTER JOIN orderheader master ON o.ord_fromorder = master.ord_number
 WHERE  (@ord_hdrnumber = 0 or o.ord_hdrnumber = @ord_hdrnumber)
	AND o.ord_startdate BETWEEN @startdt AND @enddt  
	AND (o.ord_shipper = @origin OR @origin = 'UNKNOWN')
	AND (f.fgt_shipper is not null OR f.fgt_consignee is not null)  
	--AND (isNull(f.fgt_shipper,'UNKNOWN') <> 'UNKNOWN' OR isNull(f.fgt_consignee,'UNKNONWN') <> 'UNKNOWN')  
	AND (@revtype1 = ',,' OR @revtype1 = ',UNK,' OR CHARINDEX(',' + o.ord_revtype1 + ',', @revtype1) > 0 OR o.ord_revtype1 IS NULL)  
	AND (@revtype2 = ',,' OR @revtype2 = ',UNK,' OR CHARINDEX(',' + o.ord_revtype2 + ',', @revtype2) > 0 OR o.ord_revtype2 IS NULL)  
	AND (@revtype3 = ',,' OR @revtype3 = ',UNK,' OR CHARINDEX(',' + o.ord_revtype3 + ',', @revtype3) > 0 OR o.ord_revtype3 IS NULL)  
	AND (@revtype4 = ',,' OR @revtype4 = ',UNK,' OR CHARINDEX(',' + o.ord_revtype4 + ',', @revtype4) > 0 OR o.ord_revtype4 IS NULL)  
Order By o.ord_hdrnumber, s.stp_sequence

GO
GRANT EXECUTE ON  [dbo].[inboundmanifest_rpt_02_sp] TO [public]
GO
