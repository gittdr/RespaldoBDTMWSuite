SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_ExampleOfCustomDedicatedAggregateFormula]
( @OrderNumbers   VARCHAR(MAX) = ''
, @InvoiceNumbers VARCHAR(MAX) = ''
, @Quantity       FLOAT OUTPUT
) AS
/**
 *
 * NAME:
 * dbo.sp_ExampleOfCustomDedicatedAggregateFormula
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as an exmple of how to write Dedicated Aggregated Formula in a SP
 *
 * RETURNS:
 * @Quantity float
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @OrderNumbers       VARCHAR(MAX)
 * 002 @InvoiceNumbers     VARCHAR(MAX)
 *
 * REVISION HISTORY:
 * NSUITE-201917 SPN 09/19/17 - Component Version 1
 *
 **/
 SET NOCOUNT ON;

 BEGIN

    DECLARE @ohTable table (ord_hdrnumber int);
    DECLARE @ivhTable table (ivh_hdrnumber int);

    INSERT @ohTable (ord_hdrnumber)
    SELECT CONVERT(INT, items) FROM fn_SplitString(@OrderNumbers, ',');

    INSERT @ivhTable (ivh_hdrnumber)
    SELECT CONVERT(INT, items) FROM fn_SplitString(@InvoiceNumbers, ',');

   SELECT @Quantity = SUM(stopmiles.billmiles)
     FROM (select DISTINCT stp_city, IsNull(stp_ord_mileage,0) AS billmiles from stops join @ohTable o on o.ord_hdrnumber = stops.ord_hdrnumber) stopmiles;

    RETURN;
END
GO
GRANT EXECUTE ON  [dbo].[sp_ExampleOfCustomDedicatedAggregateFormula] TO [public]
GO
