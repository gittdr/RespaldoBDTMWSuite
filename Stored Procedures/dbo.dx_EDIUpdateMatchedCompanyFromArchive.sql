SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[dx_EDIUpdateMatchedCompanyFromArchive]
	(@p_companyid VARCHAR(8),
	 @p_identity INT)
AS
 /*******************************************************************************************************************  
  Object Description:
  dx_EDIUpdateMatchedCompanyFromArchive

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  09/07/2016   David Wilks      64545        support RowSecurity GI Setting
********************************************************************************************************************/

IF ISNULL(@p_companyid,'') IN ('','UNKNOWN') RETURN -2

DECLARE @tmwuser VARCHAR(20), @xrefid INT, @v_rowsecurityForLTSL2 CHAR(1), @v_rowsecurity CHAR(1), @v_source VARCHAR(6)
--updates for tp reference
DECLARE @ord_hdrnumber INT, @tpid VARCHAR(20),@dx_sourcename VARCHAR(255)
DECLARE @dx_field004 varchar(200), @dx_field005 varchar(200), @dx_field006 varchar(200), @dx_field007 varchar(200) 
DECLARE @dx_field008 varchar(200), @dx_field009 varchar(200), @dx_field012 varchar(200), @address1 varchar(200)
--exec gettmwuser @tmwuser OUTPUT
EXEC dx_gettmwuser @tmwuser OUTPUT

SELECT @v_rowsecurity = UPPER(LEFT(gi_string1,1)) FROM generalinfo WHERE gi_name = 'RowSecurity'
IF ISNULL(@v_rowsecurity,'N') <> 'Y' SELECT @v_rowsecurity = 'N'

SELECT @v_rowsecurityForLTSL2 = UPPER(LEFT(gi_string1,1)) FROM generalinfo WHERE gi_name = 'RowSecurityForLTSL2'
IF ISNULL(@v_rowsecurityForLTSL2,'N') <> 'Y' SELECT @v_rowsecurityForLTSL2 = 'N'

IF @v_rowsecurityForLTSL2 = 'Y'
	SELECT @v_source = CASE ISNULL(cmp_BelongsTo,'UNK') WHEN 'UNK' THEN 'EDI' ELSE RTRIM(cmp_BelongsTo) END
	  FROM company
	 WHERE cmp_id = @p_companyid
ELSE
	SELECT @v_source = 'EDI'

	
	--get orderheader and tp data
	--SELECT @ord_hdrnumber = dx_orderhdrnumber FROM dx_archive WHERE dx_ident = @p_identity
	
	----retrieve tp from orderheader
	--IF(SELECT ISNULL(@ord_hdrnumber,0)) > 0
	--	SELECT @tpid = ord_editradingpartner FROM orderheader WHERE ord_hdrnumber = @ord_hdrnumber
	--ELSE 
	--	BEGIN
	--		SELECT 	@dx_sourcename = dx_sourcename FROM dx_archive WHERE dx_ident = @p_identity
			
	--		--get the tpid from the source data 02 record
	--		SELECT @tpid =  LTRIM(RTRIM(dx_field003))
	--		FROM dx_archive
	--		WHERE dx_sourcename = @dx_sourcename AND dx_field001 = '02' --and dx_field003 = '28'
	--	END

	SELECT @tpid = dx_trpid, @ord_hdrnumber = dx_orderhdrnumber, @dx_field004 = dx_field004,
		   @dx_field005 = dx_field005, @dx_field006 = dx_field006, @dx_field007 = dx_field007,
		   @dx_field008 = dx_field008, @dx_field009 = dx_field009, @dx_field012 = IsNull(dx_field012,'')
		   FROM dx_archive_header ah (nolock)
		   JOIN dx_archive_detail ad (nolock) on ah.dx_Archive_header_id = ad.dx_Archive_header_id
		   WHERE dx_ident = @p_identity

		   if RTRIM(ISNULL(@dx_field012,'')) <> '' 
			    SET @address1 = @dx_field012
		   ELSE
				SET @address1 = @dx_field005
	
IF @v_rowsecurity = 'Y'	
	SELECT @xrefid = xref.cmp_xref_id 
	  FROM company_xref xref
	  inner join company c on xref.cmp_xref_id = c.cmp_id
	  inner join RowRestrictValidAssignments_company_fn() rsva on (c.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
		WHERE xref.cmp_name = @dx_field004
	   AND xref.address1 = @address1 
	   AND xref.address2 = @dx_field006
	   AND xref.city = @dx_field007
	   AND xref.state = @dx_field008
	   AND xref.zip = @dx_field009
ELSE
	IF @v_rowsecurityForLTSL2 = 'Y'	
	SELECT @xrefid = xref.cmp_xref_id 
	  FROM company_xref xref
		WHERE xref.cmp_name = @dx_field004
	   AND xref.address1 = @address1 
	   AND xref.address2 = @dx_field006
	   AND xref.city = @dx_field007
	   AND xref.state = @dx_field008
	   AND xref.zip = @dx_field009
	   and xref.src_system = @v_source
	ELSE -- no row security
		SELECT @xrefid = xref.cmp_xref_id 
		  FROM company_xref xref
		  WHERE xref.cmp_name = @dx_field004
		   AND xref.address1 = @address1
		   AND xref.address2 = @dx_field006
		   AND xref.city = @dx_field007
		   AND xref.state = @dx_field008
		   AND xref.zip = @dx_field009

IF @xrefid IS NULL
	INSERT company_xref
		(cmp_id, cmp_name, address1, address2, city, STATE, zip, crt_date, src_system, upd_date, upd_count, upd_by,src_tradingpartner)
	SELECT @p_companyid, @dx_field004, @address1, @dx_field006, @dx_field007, @dx_field008, @dx_field009
	     , GETDATE(), @v_source, GETDATE(), 1, @tmwuser,@tpid
ELSE
	IF @v_rowsecurityForLTSL2 = 'Y'	
		UPDATE company_xref
		   SET cmp_id = @p_companyid
			 , upd_date = GETDATE()
			 , upd_count = upd_count + 1
			 , upd_by = @tmwuser
			 , src_tradingpartner = @tpid
		 WHERE cmp_xref_id = @xrefid
		   and src_system = @v_source
	ELSE
		UPDATE company_xref
		   SET cmp_id = @p_companyid
			 , upd_date = GETDATE()
			 , upd_count = upd_count + 1
			 , upd_by = @tmwuser
			 , src_tradingpartner = @tpid
		 WHERE cmp_xref_id = @xrefid

IF @@ERROR <> 0 
	RETURN -1

RETURN 1

GO
GRANT EXECUTE ON  [dbo].[dx_EDIUpdateMatchedCompanyFromArchive] TO [public]
GO
