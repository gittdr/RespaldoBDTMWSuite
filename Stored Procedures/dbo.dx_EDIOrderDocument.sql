SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDIOrderDocument]
	@p_OrderNumber VARCHAR(50),
	@p_DocumentNumber VARCHAR(30),
	@p_SourceDate DATETIME,
	@p_ImportID VARCHAR(8)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_EDIOrderDocument

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

	DECLARE	@sourcedates TABLE
		(sourcedate datetime, diff int)

	INSERT	@sourcedates (sourcedate)
	SELECT	
		DISTINCT dx_sourcedate
	FROM
		dx_archive WITH (NOLOCK)
	WHERE
		dx_importid = @p_ImportID
	AND
		dx_ordernumber = @p_OrderNumber
	AND
		dx_docnumber = @p_DocumentNumber
	AND
		ABS(DATEDIFF(ss, dx_sourcedate, @p_SourceDate)) <= 1

	UPDATE  @sourcedates
	SET     diff = ABS(DATEDIFF(ms, sourcedate, @p_SourceDate))

	DECLARE	@maxdate datetime
	SELECT  @maxdate = (SELECT TOP 1 sourcedate FROM @sourcedates ORDER BY diff)

	SELECT 
		dx_ident, dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, dx_accepted, 
		dx_ordernumber, 
		case @p_importID when 'dx_204' then orderheader.ord_number else dx_orderhdrnumber end as 'dx_orderhdrnumber', 
		dx_movenumber, dx_stopnumber, dx_freightnumber, 
		dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype, 
		dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006, dx_field007, 
		dx_field008, dx_field009, dx_field010, dx_field011, dx_field012, dx_field013, dx_field014, 
		dx_field015, dx_field016, dx_field017, dx_field018, dx_field019, dx_field020, dx_field021, 
		dx_field022, dx_field023, dx_field024, dx_field025, dx_field026, dx_field027, dx_field028, 
		dx_field029, dx_field030, dx_processed 
	FROM 
		dx_archive WITH (NOLOCK)
	LEFT OUTER JOIN
		orderheader (NOLOCK)
	ON
		dx_archive.dx_orderhdrnumber = orderheader.ord_hdrnumber
	WHERE 
		    (dx_docnumber = @p_DocumentNumber) 
		AND 
		    (dx_sourcedate = @maxdate)
		AND
		    (dx_ordernumber = @p_OrderNumber)
		AND 
		    (dx_importid = @p_ImportID)  
	ORDER BY dx_seq

GO
GRANT EXECUTE ON  [dbo].[dx_EDIOrderDocument] TO [public]
GO
