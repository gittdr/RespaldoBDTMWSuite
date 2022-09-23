SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE   proc [dbo].[dx_get_scac]
	(@p_ordhdr int, @SCAC varchar(60) = '' output)
as

 /*******************************************************************************************************************  
  Object Description:
  dx_get_scac

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  09/07/2016   David Wilks      99730        support trading partner wrapper setting 
********************************************************************************************************************/

DECLARE @revstart int, @revtype varchar(8), @ordrevtype varchar(6), 
              @sourceident int, @etp_ExportWrapper varchar(6)
      
       SELECT @SCAC = ISNULL(MAX(ISNULL(ref_number,'')),'')
         FROM referencenumber
       WHERE ref_tablekey = @p_ordhdr
          AND ref_table = 'orderheader'
          AND ref_type = 'SCA'


		
		SELECT @etp_ExportWrapper = etp_ExportWrapper
		FROM edi_tender_partner 
		JOIN orderheader on orderheader.ord_editradingpartner = edi_tender_partner.etp_partnerID 
		WHERE ord_hdrnumber = @p_ordhdr

		IF @etp_ExportWrapper is null or @etp_ExportWrapper = ''
			SELECT @etp_ExportWrapper = IsNull(gi_string1,'FULL')
			FROM generalinfo WHERE gi_name = 'EDI990WrapOverride'

          
       IF ISNULL(@SCAC,'') = '' OR @etp_ExportWrapper = 'FULL' 
       BEGIN
              SELECT @sourceident = MAX(dx_ident) FROM dx_archive WITH (NOLOCK)
              WHERE dx_orderhdrnumber = @p_ordhdr
                 AND dx_importid = 'dx_204'
                 AND dx_field001 = '02'
              
              SELECT @SCAC = RTRIM(ISNULL(dx_field020,''))
                FROM dx_Archive_detail WITH (NOLOCK)
              WHERE dx_ident = @sourceident

              IF @SCAC = '' OR @etp_ExportWrapper = 'FULL' 
              BEGIN
                     SELECT  @SCAC=ISNULL(UPPER(gi_string1), 'SCAC')
                       FROM generalinfo 
                      WHERE gi_name='SCAC'
                     
                     -- Is SCAC based on RevType? get from labelfile
                     SELECT  @revstart = CHARINDEX('REVTYPE',@SCAC,1)
                     
                     IF @revstart > 1
                     BEGIN
                        SELECT @revtype = SUBSTRING(@SCAC,@revstart,8)
                     
                        SELECT @ordrevtype = 
                            Case @revtype
                              When 'REVTYPE1' Then ord_revtype1
                              When 'REVTYPE2' Then ord_revtype2
                              When 'REVTYPE3' Then ord_revtype3
                              When 'REVTYPE4' Then ord_revtype4
                              Else ord_revtype1
                           End
                        FROM orderheader
                        WHERE ord_hdrnumber = @p_ordhdr
                       
                        SELECT @SCAC = isnull(edicode,abbr)
                        FROM labelfile
                        WHERE labeldefinition = @revtype
                        AND    abbr = @ordrevtype
                     
                        IF LEN(RTRIM(@SCAC)) = 0 
                              SELECT @SCAC = 'ERRL' 
                     
                     END
              END
       END
       --SCAC is returned in the @SCAC output parameter and by the following scalar output                    

       SELECT isnull(upper(left(@SCAC, 4)), 'SCAC')


GO
GRANT EXECUTE ON  [dbo].[dx_get_scac] TO [public]
GO
