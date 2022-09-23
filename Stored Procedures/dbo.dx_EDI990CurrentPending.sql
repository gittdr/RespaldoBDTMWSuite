SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[dx_EDI990CurrentPending]

AS
	DECLARE @holdname varchar(60)
	
	DECLARE @current990s table
		(est_Ident int, ord_hdrnumber int, est_Order_Number varchar(30),
		 est_DocumentNumber varchar(30), est_SourceDate datetime, trp_id varchar(20),
		 est_990State int, est_ExportPath varchar(240), est_ExportWrapper varchar(4))
	
	--change 3.02.09.01 AR - updated select for current pensing 990 data
	INSERT @current990s
		(est_Ident, ord_hdrnumber, est_Order_Number, est_DocumentNumber, 
		 est_SourceDate, trp_id, est_990State, est_ExportPath, est_ExportWrapper)
	SELECT 
		est_Ident, ord_hdrnumber, est_Order_Number, 
		est_DocumentNumber, est_SourceDate est_SourceDate, trp_id, 
		1 est_990State, ISNULL(etp_ExportPath,'') as 'est_ExportPath', ISNULL(etp_ExportWrapper,'') as 'est_ExportWrapper'
	FROM
		dx_EDI990State
	LEFT OUTER JOIN
		edi_tender_partner
	ON
		dx_EDI990State.trp_id = edi_tender_partner.etp_partnerID
	WHERE 
		est_990State='1'
	--end 3.02.09.01 AR	
	/*INSERT @current990s
		(est_Ident, ord_hdrnumber, est_Order_Number, est_DocumentNumber, 
		 est_SourceDate, trp_id, est_990State, est_ExportPath, est_ExportWrapper)
	SELECT 
		MAX(est_Ident) est_Ident, ord_hdrnumber, est_Order_Number, 
		est_DocumentNumber, MAX(est_SourceDate) est_SourceDate, trp_id, 
		1 est_990State, ISNULL(etp_ExportPath,'') as 'est_ExportPath', ISNULL(etp_ExportWrapper,'') as 'est_ExportWrapper'
	FROM
		dx_EDI990State
	LEFT OUTER JOIN
		edi_tender_partner
	ON
		dx_EDI990State.trp_id = edi_tender_partner.etp_partnerID
	WHERE 
		est_990State='1'
	GROUP BY
		trp_id, est_DocumentNumber, est_Order_Number, ord_hdrnumber, etp_ExportPath, etp_ExportWrapper
	*/
	
	SELECT @holdname = ISNULL(gi_string2,'') FROM generalinfo WHERE gi_name = 'LTSLResponseOverrides'
	
	IF ISNULL(@holdname,'') > ''
	BEGIN
		DELETE 
			current990s
		FROM
			@current990s current990s
		INNER JOIN
			orderheader
		ON
			current990s.ord_hdrnumber = orderheader.ord_hdrnumber
		WHERE
			trp_id IN (SELECT etp_partnerID from edi_tender_partner WHERE etp_PartnerName LIKE @holdname)
		AND
			ord_status IN ('PND','AVL')
	END

    SELECT * 
		FROM @current990s	
	ORDER BY
		trp_id, est_SourceDate
GO
GRANT EXECUTE ON  [dbo].[dx_EDI990CurrentPending] TO [public]
GO
