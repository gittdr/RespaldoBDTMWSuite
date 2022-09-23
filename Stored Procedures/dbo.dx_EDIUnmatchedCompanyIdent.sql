SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[dx_EDIUnmatchedCompanyIdent] (@p_ordhdr INT,@dx_status VARCHAR (50),@NoUpdate bit = 0)  
AS  
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  
DECLARE @v_sourcedate DATETIME, @v_purpose CHAR(1)  

DECLARE @cmp_name VARCHAR(30)
	,@cmp_city INT
	,@cmp_zip VARCHAR(10)
	,@cmp_address1 VARCHAR(100)
	,@cmp_address2 VARCHAR(100)
	,@cmp_contact NVARCHAR(80)
	,@cmp_phone VARCHAR(10)
DECLARE @cmp_revtype1 VARCHAR(6)
	,@cmp_revtype2 VARCHAR(6)
	,@cmp_revtype3 VARCHAR(6)
	,@cmp_revtype4 VARCHAR(6)
	,@cmp_mileagetable VARCHAR(2)
  
SELECT @v_sourcedate = MAX(dx_sourcedate)  
  FROM dx_archive WITH (NOLOCK)  
 WHERE dx_importid = 'dx_204'  
   AND dx_orderhdrnumber = @p_ordhdr   AND dx_processed=@dx_status
  
IF @v_sourcedate IS NULL RETURN 0  
  
--don't match on cancelled or refused orders  
SELECT @v_purpose = LEFT(dx_field004,1)  
  FROM dx_archive WITH (NOLOCK)  
 WHERE dx_importid = 'dx_204'  
   AND dx_sourcedate = @v_sourcedate  
   AND dx_orderhdrnumber = @p_ordhdr  
   AND dx_field001 = '02'  
     
IF @v_purpose IN ('C','R') RETURN 0  
  
DECLARE @cmpmatches TABLE  
 (Ident INT, OrderHdrNumber INT, MoveNumber INT, StopNumber INT, CompanyType VARCHAR(2), CompanyName VARCHAR(35),  
  Address1 VARCHAR(100), Address2 VARCHAR(100), City VARCHAR(20), STATE VARCHAR(2), Zip VARCHAR(9), Country VARCHAR(3),   
  TmwStopID VARCHAR(8),cmpaltid VARCHAR(50))  
  
INSERT @cmpmatches  
 (Ident, OrderHdrNumber, MoveNumber, StopNumber, CompanyType, CompanyName, Address1,  
  Address2, City, STATE, Zip, Country, TmwStopID,cmpaltid)  
SELECT dx_ident, dx_orderhdrnumber, dx_movenumber, dx_stopnumber, dx_field003, dx_field004 
	 , CASE RTRIM(ISNULL(dx_field012,'')) WHEN '' THEN dx_field005 ELSE dx_field012 END  
     , dx_field006, dx_field007, dx_field008, dx_field009, dx_field010  
     , CASE dx_field003 WHEN 'SH' THEN ord_company  
   WHEN 'BT' THEN ord_billto  
   WHEN 'ST' THEN stops.cmp_id ELSE NULL END ,dx_field013 
  FROM dx_archive WITH (NOLOCK)  
 INNER JOIN orderheader WITH (NOLOCK)
    ON dx_orderhdrnumber = orderheader.ord_hdrnumber  
  LEFT JOIN stops WITH (NOLOCK)
    ON dx_stopnumber = stops.stp_number  
 WHERE dx_importid = 'dx_204'  
   AND dx_orderhdrnumber = @p_ordhdr  
   AND dx_sourcedate = @v_sourcedate  
   AND dx_field001 = '06'  
   AND dx_field003 IN ('SH','BT','ST')  
   AND dx_field004 <> 'UNKNOWN'  
 ORDER BY dx_ident 
  
  IF @dx_status='MOD'
	BEGIN
  		DELETE @cmpmatches WHERE ISNULL(TmwStopID,'UNKNOWN') <> 'UNKNOWN'  
  	END
  ELSE
		BEGIN
			DELETE @cmpmatches WHERE ISNULL(TmwStopID,'') <> 'UNKNOWN'  
		END
		
  		
  
IF (SELECT COUNT(1) FROM @cmpmatches) = 0 RETURN 0  
  
DECLARE @v_ident INT, @v_cmpid VARCHAR(8), @v_cmptype VARCHAR(2), @v_miles INT, @v_movnum INT,   
 @v_ordnum INT, @v_retcode INT, @v_stpnum INT, @v_stpseq INT, @v_billto VARCHAR(8),   
 @v_setbillto VARCHAR(8), @v_revtypesource CHAR(1), @v_ordstatus VARCHAR(6), @v_rowsecurity CHAR(1), @v_rowsecurityforltsl2 CHAR(1), @v_source VARCHAR(6)  

SELECT @v_ident = MIN(Ident) FROM @cmpmatches 
IF (@NoUpdate=1) RETURN ISNULL(@v_ident, 0)  

SELECT @v_ident = 0, @v_setbillto = 'UNKNOWN'  
  
SELECT @v_revtypesource = ifc_value FROM interface_constants   
 WHERE ifc_tablename = 'misc' AND ifc_columnname = 'revtypesource'  
   
SELECT @v_rowsecurity = UPPER(LEFT(gi_string1,1)) FROM generalinfo WHERE gi_name = 'RowSecurity'  
IF ISNULL(@v_rowsecurity,'N') <> 'Y' SELECT @v_rowsecurity = 'N'  

SELECT @v_rowsecurityforltsl2 = UPPER(LEFT(gi_string1,1)) FROM generalinfo WHERE gi_name = 'RowSecurityForLTSL2'  
IF ISNULL(@v_rowsecurityforltsl2,'N') <> 'Y' SELECT @v_rowsecurityforltsl2 = 'N'  

  
SELECT @v_billto = ord_billto, @v_ordstatus = ord_status, @v_source = CASE WHEN @v_rowsecurityforltsl2 <> 'Y' THEN 'EDI'   
                     WHEN ISNULL(ord_BelongsTo,'UNK') = 'UNK' THEN 'EDI'  
                     ELSE RTRIM(ord_BelongsTo) END  
  FROM orderheader  
 WHERE ord_hdrnumber = @p_ordhdr  
  
WHILE 1=1  
BEGIN  
 SELECT @v_ident = MIN(Ident) FROM @cmpmatches WHERE Ident > @v_ident  
 IF @v_ident IS NULL  
  BREAK  
 SELECT @v_cmpid = NULL  
 IF @v_rowsecurityforltsl2 = 'Y'
	 SELECT @v_cmpid = MAX(xref.cmp_id)  
	   FROM company_xref xref  (nolock) 
	  INNER JOIN @cmpmatches dx ON xref.cmp_name = dx.CompanyName  
	  		AND xref.address1 = dx.Address1  
			AND xref.city = dx.City  
			AND xref.state = dx.State  
			and xref.src_system = @v_source  
	  join company (nolock) on xref.cmp_id = company.cmp_id  
	  WHERE dx.Ident = @v_ident  
	  AND IsNull(company.cmp_active,'Y') = 'Y'
  ELSE
	  SELECT @v_cmpid = MAX(xref.cmp_id)  
	   FROM company_xref xref  
	  INNER JOIN @cmpmatches dx  
		 ON xref.cmp_name = dx.CompanyName  
		AND xref.address1 = dx.Address1  
		AND xref.city = dx.City  
		AND xref.state = dx.State  
	  join company (nolock) on xref.cmp_id = company.cmp_id  
	  WHERE dx.Ident = @v_ident  
	  AND IsNull(company.cmp_active,'Y') = 'Y'
  
   IF @dx_status='MOD'
	BEGIN
  		IF @v_cmpid IS NULL
  		BEGIN
  			
						SELECT @v_cmpid = MAX(cmp_id)     FROM company cmp    INNER JOIN @cmpmatches dx       ON   cmp.cmp_altid = dx.cmpaltid  WHERE dx.Ident = @v_ident and dx.cmpaltid  <> '' and IsNull(cmp_active,'Y') = 'Y'
  			IF @v_cmpid IS NULL
  			BREAK 
  		END
  		
  	END
  ELSE
		BEGIN
			 IF @v_cmpid IS NULL  
				BREAK  
   
		END
  
  
 IF @v_cmpid IS NULL  
  BREAK  
  
 IF (SELECT COUNT(1) FROM company WHERE cmp_id = @v_cmpid) = 0 OR @v_cmpid = 'UNKNOWN'  
 BEGIN  
  DELETE company_xref WHERE cmp_id = @v_cmpid  
  SELECT @v_ident = @v_ident - 1  
  CONTINUE  
 END  
   
 
 SELECT @v_ordnum = OrderHdrNumber  
      , @v_movnum = MoveNumber  
      , @v_stpnum = StopNumber  
      , @v_cmptype = CompanyType  
   FROM @cmpmatches WHERE Ident = @v_Ident  
  
 IF @v_cmptype = 'ST'  
 BEGIN  
  SELECT @v_stpseq = stp_sequence FROM stops WHERE stp_number = @v_stpnum  
  IF @v_stpseq = 1  
   SELECT @v_cmptype = 'SU'  
  ELSE IF @v_stpseq = (SELECT MAX(stp_sequence) FROM stops WHERE ord_hdrnumber = @v_ordnum)  
   SELECT @v_cmptype = 'CO'  
 END  
  
 SELECT @v_miles = CASE @v_cmptype WHEN 'SU' THEN NULL ELSE -1 END  
  
 IF ISNULL(@v_ordnum,0) = 0 OR ISNULL(@v_movnum,0) = 0 OR (ISNULL(@v_stpnum,0) = 0 AND @v_cmptype IN ('SU','CO','ST'))  
  CONTINUE  
  
 IF @v_cmptype = 'SH' AND @v_billto = 'UNKNOWN'  
  EXEC dx_get_default_billto @v_cmpid, @v_setbillto OUTPUT  

  declare  @v_type varchar(8), @stp_event varchar(6),
		@ls_UseCompanyDefaultEventCodes char(1)

 SELECT @ls_UseCompanyDefaultEventCodes = gi_string1 FROM generalinfo WHERE gi_name = 'UseCompanyDefaultEventCodes'
 

     IF @ls_UseCompanyDefaultEventCodes = 'Y'
		  BEGIN
		  set @stp_event = null
		  if @v_type is null
			select @v_type = stp_type, @stp_event = stp_event from stops where stp_number = @v_stpnum
		  IF @v_type = 'PUP'
			  SELECT @stp_event = IsNull(ltsl_default_pickup_event,@stp_event)
			FROM company WHERE cmp_id = @v_cmpid and ltsl_default_pickup_event <> ''
		  IF @v_type = 'DRP'
			  SELECT @stp_event = IsNull(ltsl_default_delivery_event,@stp_event)
	   		FROM company WHERE cmp_id = @v_cmpid and ltsl_default_delivery_event <> ''
		  END
  
  	SELECT @cmp_name = cmp_name
		,@cmp_city = cmp_city
		,@cmp_zip = cmp_zip
		,@cmp_address1 = SUBSTRING(cmp_address1, 0, 40)
		,@cmp_address2 = SUBSTRING(cmp_address2, 0, 40)
		,@cmp_contact = cmp_contact
		,@cmp_phone = cmp_primaryphone
		,@cmp_mileagetable = ISNULL(cmp_mileagetable, 0)
		,@cmp_revtype1 = ISNULL(cmp_revtype1, 'UNK')
		,@cmp_revtype2 = ISNULL(cmp_revtype2, 'UNK')
		,@cmp_revtype3 = ISNULL(cmp_revtype3, 'UNK')
		,@cmp_revtype4 = ISNULL(cmp_revtype4, 'UNK')
	FROM company
	WHERE cmp_id = @v_cmpid

  BEGIN
		IF @v_cmptype IN (
				'SU'
				,'CO'
				,'ST'
				)
		BEGIN
			IF EXISTS (
					SELECT stp_number
					FROM stops
					WHERE stp_number = @v_stpnum
						AND (
							cmp_id <> @v_cmpid
							OR cmp_name <> @cmp_name
							OR stp_city <> @cmp_city
							OR stp_zipcode <> @cmp_zip
							OR stp_address <> @cmp_address1
							OR stp_address2 <> @cmp_address2
							OR stp_contact <> @cmp_contact
							OR stp_phonenumber <> @cmp_phone
							OR stp_ord_mileage <> ISNULL(@v_miles, 0)
							OR stp_lgh_mileage <> @v_miles
							OR stp_event <> @stp_event
							)
					)
				UPDATE stops
				SET stops.cmp_id = @v_cmpid
					,stops.cmp_name = @cmp_name
					,stops.stp_city = @cmp_city
					,stops.stp_zipcode = @cmp_zip
					,stops.stp_address = @cmp_address1
					,stops.stp_address2 = @cmp_address2
					,stops.stp_contact = @cmp_contact
					,stp_phonenumber = @cmp_phone
					,stops.stp_ord_mileage = ISNULL(@v_miles, 0)
					,stops.stp_lgh_mileage = @v_miles
					,stops.stp_event = IsNull(@stp_event,stp_event)
				WHERE stops.stp_number = @v_stpnum
		END
  
  IF @v_cmptype = 'SU'
		BEGIN
			IF @v_revtypesource = 'S'
				AND @v_ordstatus = 'PND'
			BEGIN
				IF EXISTS (
						SELECT ord_hdrnumber
						FROM orderheader
						WHERE ord_hdrnumber = @v_ordnum
							AND (
								ord_originpoint <> @v_cmpid
								OR ord_showshipper <> @v_cmpid
								OR ord_shipper <> @v_cmpid
								OR ord_origincity <> @cmp_city
								OR ord_origin_zip <> @cmp_zip
								OR ord_revtype1 <> @cmp_revtype1
								OR ord_revtype2 <> @cmp_revtype2
								OR ord_revtype3 <> @cmp_revtype3
								OR ord_revtype4 <> @cmp_revtype4
								)
						)
					UPDATE orderheader
					SET ord_originpoint = @v_cmpid
						,ord_showshipper = @v_cmpid
						,ord_shipper = @v_cmpid
						,ord_origincity = @cmp_city
						,ord_origin_zip = @cmp_zip
						,ord_revtype1 = @cmp_revtype1
						,ord_revtype2 = @cmp_revtype2
						,ord_revtype3 = @cmp_revtype3
						,ord_revtype4 = @cmp_revtype4
					WHERE ord_hdrnumber = @v_ordnum
			END
			ELSE IF EXISTS (
					SELECT ord_hdrnumber
					FROM orderheader
					WHERE ord_hdrnumber = @v_ordnum
						AND (
							ord_originpoint <> @v_cmpid
							OR ord_showshipper <> @v_cmpid
							OR ord_shipper <> @v_cmpid
							OR ord_origincity <> @cmp_city
							OR ord_origin_zip <> @cmp_zip
							)
					)
				UPDATE orderheader
				SET ord_originpoint = @v_cmpid
					,ord_showshipper = @v_cmpid
					,ord_shipper = @v_cmpid
					,ord_origincity = @cmp_city
					,ord_origin_zip = @cmp_zip
				WHERE ord_hdrnumber = @v_ordnum
		END 
  
  IF @v_cmptype = 'CO'
		BEGIN
			IF @v_revtypesource = 'C'
				AND @v_ordstatus = 'PND'
			BEGIN
				IF EXISTS (
						SELECT ord_hdrnumber
						FROM orderheader
						WHERE ord_hdrnumber = @v_ordnum
							AND (
								ord_destpoint <> @v_cmpid
								OR ord_showcons <> @v_cmpid
								OR ord_consignee <> @v_cmpid
								OR ord_destcity <> @cmp_city
								OR ord_dest_zip <> @cmp_zip
								OR ord_revtype1 <> @cmp_revtype1
								OR ord_revtype2 <> @cmp_revtype2
								OR ord_revtype3 <> @cmp_revtype3
								OR ord_revtype4 <> @cmp_revtype4
								)
						)
				BEGIN
					UPDATE orderheader
					SET ord_destpoint = @v_cmpid
						,ord_showcons = @v_cmpid
						,ord_consignee = @v_cmpid
						,ord_destcity = @cmp_city
						,ord_dest_zip = @cmp_zip
						,ord_revtype1 = @cmp_revtype1
						,ord_revtype2 = @cmp_revtype2
						,ord_revtype3 = @cmp_revtype3
						,ord_revtype4 = @cmp_revtype4
					WHERE ord_hdrnumber = @v_ordnum
				END
			END
			ELSE
			BEGIN
				IF EXISTS (
						SELECT ord_hdrnumber
						FROM orderheader
						WHERE ord_hdrnumber = @v_ordnum
							AND (
								ord_destpoint <> @v_cmpid
								OR ord_showcons <> @v_cmpid
								OR ord_consignee <> @v_cmpid
								OR ord_destcity <> @cmp_city
								OR ord_dest_zip <> @cmp_zip
								)
						)
				BEGIN
					UPDATE orderheader
					SET ord_destpoint = @v_cmpid
						,ord_showcons = @v_cmpid
						,ord_consignee = @v_cmpid
						,ord_destcity = c.cmp_city
						,ord_dest_zip = c.cmp_zip
					FROM company c
					WHERE ord_hdrnumber = @v_ordnum
						AND c.cmp_id = @v_cmpid
				END
			END
		END
  
		IF @v_cmptype = 'SH'
		BEGIN
			IF EXISTS (
					SELECT ord_hdrnumber
					FROM orderheader
					WHERE ord_hdrnumber = @v_ordnum
						AND ord_company <> @v_cmpid
					)
				UPDATE orderheader
				SET ord_company = @v_cmpid
				WHERE ord_hdrnumber = @v_ordnum

			IF @v_setbillto <> 'UNKNOWN'
				SELECT @v_cmpid = @v_setbillto
					,@v_cmptype = 'BT'
		END
  
 IF @v_cmptype = 'BT'
		BEGIN
			SET @v_billto = @v_cmpid

			IF @v_revtypesource = 'B'
				AND @v_ordstatus = 'PND'
			BEGIN
				IF EXISTS (
						SELECT ord_hdrnumber
						FROM orderheader
						WHERE ord_hdrnumber = @v_ordnum
							AND (
								ord_billto <> @v_cmpid
								OR ord_revtype1 <> @cmp_revtype1
								OR ord_revtype2 <> @cmp_revtype2
								OR ord_revtype3 <> @cmp_revtype3
								OR ord_revtype4 <> @cmp_revtype4
								OR (
									@cmp_mileagetable <> 0
									AND @cmp_mileagetable <> ord_mileagetable
									)
								)
						)
				BEGIN
					UPDATE orderheader
					SET ord_billto = @v_cmpid
						,ord_mileagetable = CASE @cmp_mileagetable
							WHEN 0
								THEN ord_mileagetable
							ELSE @cmp_mileagetable
							END
						,ord_revtype1 = @cmp_revtype1
						,ord_revtype2 = @cmp_revtype2
						,ord_revtype3 = @cmp_revtype3
						,ord_revtype4 = @cmp_revtype4
					WHERE ord_hdrnumber = @v_ordnum
				END
			END
			ELSE
			BEGIN
				IF EXISTS (
						SELECT ord_hdrnumber
						FROM orderheader
						WHERE ord_hdrnumber = @v_ordnum
							AND (
								ord_billto <> @v_cmpid
								OR (
									@cmp_mileagetable <> 0
									AND @cmp_mileagetable <> ord_mileagetable
									)
								)
						)
				BEGIN
					UPDATE orderheader
					SET ord_billto = @v_cmpid
						,ord_mileagetable = CASE @cmp_mileagetable
							WHEN 0
								THEN ord_mileagetable
							ELSE @cmp_mileagetable
							END
					WHERE ord_hdrnumber = @v_ordnum
				END
			END
		END
	END 
   
 EXEC dbo.update_ord @v_movnum, 'UNK'  
 EXEC dbo.update_move @v_movnum  
   
 IF @v_billto <> 'UNKNOWN'  
 BEGIN  
  IF @v_cmptype IN ('SU','CO','ST')  
   EXEC dx_update_n104_from_stop @v_stpnum, @v_billto  
  IF @v_cmptype = 'BT'  --BT changed, so we have to loop through all stops  
  BEGIN  
   SELECT @v_stpnum = 0  
   WHILE 1=1  
   BEGIN  
    SELECT @v_stpnum = MIN(stp_number) FROM stops WHERE ord_hdrnumber = @v_ordnum AND stp_number > @v_stpnum  
    IF @v_stpnum IS NULL BREAK  
    EXEC dx_update_n104_from_stop @v_stpnum, @v_billto  
   END  
  END  
 END  
END  
  
RETURN ISNULL(@v_ident, 0)  

GO
GRANT EXECUTE ON  [dbo].[dx_EDIUnmatchedCompanyIdent] TO [public]
GO
