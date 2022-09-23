SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[update_inv_sp] (@asset_type AS Char(3), @asset Char(13), @inv_by_user as Char(20)) AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
	8/8/2006 PTS 33485 BDH - Added ta_source column to trlaccessories to distinguish between trailer accessories and carrier trailer accessories.
			 Added tca_source column to tractoraccesories to distinguish between tractor accessories and carrier tractor accessories.
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @invdate DateTime

SELECT @invdate=GETDATE()

IF UPPER(@asset_type) = 'TRC' 
BEGIN
-- PTS 24209 -- BL (start)
--    INSERT INTO inventory_log 
    INSERT INTO inventory_log (il_trailer, il_tractor, il_type, il_quantity, il_inventory_by, il_inventory_date)
-- PTS 24209 -- BL (end)
    SELECT NULL,
           ISNULL(dbo.tractoraccesories.tca_tractor, UPPER(@asset)),
           dbo.labelfile.abbr,
           ISNULL(dbo.tractoraccesories.tca_quantitiy, 0),
           @inv_by_user,
           @invdate
    FROM   dbo.tractoraccesories RIGHT OUTER JOIN dbo.labelfile ON  (dbo.tractoraccesories.tca_type = dbo.labelfile.abbr 
																	and dbo.tractoraccesories.tca_tractor = @asset
																	and dbo.tractoraccesories.tca_source = 'TRC')
    WHERE  --( dbo.tractoraccesories.tca_type =* dbo.labelfile.abbr) and  
           --( ( dbo.tractoraccesories.tca_tractor = @asset ) AND  
           ( dbo.labelfile.labeldefinition = 'TrcAcc' ) AND  
           ( dbo.labelfile.inventory_item = 'Y' ) 
		-- 33485 BDH start	
	    --( dbo.tractoraccesories.tca_source = 'TRC' ))
		-- 33485 BDH end

END
ELSE
    IF UPPER(@asset_type) = 'TRL'
    BEGIN
-- PTS 24209 -- BL (start)
--        INSERT INTO inventory_log 
        INSERT INTO inventory_log (il_trailer, il_tractor, il_type, il_quantity, il_inventory_by, il_inventory_date)
-- PTS 24209 -- BL (end)
        SELECT ISNULL(dbo.trlaccessories.ta_trailer, UPPER(@asset)),
               NULL,
               dbo.labelfile.abbr,
               ISNULL(dbo.trlaccessories.ta_quantity, 0),
               @inv_by_user,
               @invdate
        FROM   dbo.trlaccessories RIGHT OUTER JOIN dbo.labelfile ON ( dbo.trlaccessories.ta_type = dbo.labelfile.abbr 
												and dbo.trlaccessories.ta_trailer = @asset  
												and dbo.trlaccessories.ta_source = 'TRL')  --pts40464 outer join conversion
        WHERE  --( dbo.trlaccessories.ta_type =* dbo.labelfile.abbr) and  
               --( ( dbo.trlaccessories.ta_trailer = @asset ) AND  
               ( dbo.labelfile.labeldefinition = 'TrlAcc' ) AND  
               ( dbo.labelfile.inventory_item = 'Y' ) 
		-- 33485 BDH start	
	       --( dbo.trlaccessories.ta_source = 'TRL' ))
		-- 33485 BDH end

    END

GO
GRANT EXECUTE ON  [dbo].[update_inv_sp] TO [public]
GO
