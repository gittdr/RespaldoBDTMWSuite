SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_load_cmdid_for_dddw_intelli_sp] 
( @billto   VARCHAR(8)
, @revtype1 VARCHAR(6)
, @revtype2 VARCHAR(6)
, @revtype3 VARCHAR(6)
, @revtype4 VARCHAR(6)
) AS 
/**
 *
 * NAME:
 * dbo.d_load_cmdid_for_dddw_intelli_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for datawindow d_load_cmdid_for_dddw_intelli
 *
 * RETURNS:
 *
 * RESULT SETS:
 *
 * PARAMETERS:
 * 001 @billto   VARCHAR(8)
 * 002 @revtype1 VARCHAR(6)
 * 003 @revtype2 VARCHAR(6)
 * 004 @revtype3 VARCHAR(6)
 * 005 @revtype4 VARCHAR(6)
 *
 * REVISION HISTORY:
 * PTS 56318 SPN 05/20/11 - Initial Version Created
 * 
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @heirarchy_specificity INT
   DECLARE @billto_restricted     CHAR(1)
   
   DECLARE @temp TABLE
   ( code                  VARCHAR(8)  NULL
   , name                  VARCHAR(60) NULL
   , cmd_non_spec          INT         NULL
   , cmd_flash_point       FLOAT       NULL
   , cmd_flash_unit        VARCHAR(6)  NULL
   , cmd_flash_point_max   FLOAT       NULL
   , cmd_taxtable1         CHAR(1)     NULL
   , cmd_taxtable2         CHAR(1)     NULL
   , cmd_taxtable3         CHAR(1)     NULL
   , cmd_taxtable4         CHAR(1)     NULL
   , heirarchy_specificity INT         NULL
   )

   SELECT @billto   = IsNull(@billto,'UNKNOWN')
   SELECT @revtype1 = IsNull(@revtype1,'UNK')
   SELECT @revtype2 = IsNull(@revtype2,'UNK')
   SELECT @revtype3 = IsNull(@revtype3,'UNK')
   SELECT @revtype4 = IsNull(@revtype4,'UNK')

   --Restrict to this BillTo?
   BEGIN
      SELECT @billto_restricted = 'Y'
      IF @billto <> 'UNKNOWN'
         IF (SELECT COUNT(1) FROM commodity_linkto WHERE billto = @billto) <= 0
            SELECT @billto_restricted = 'N'
   END

   --Find all commodities matching one/more arguments and determine specificity
   IF NOT ( @billto   = 'UNKNOWN' AND
            @revtype1 = 'UNK' AND
            @revtype2 = 'UNK' AND
            @revtype3 = 'UNK' AND
            @revtype4 = 'UNK'
          )
      BEGIN
         
         INSERT INTO @temp
         ( code
         , name
         , cmd_non_spec
         , cmd_flash_point
         , cmd_flash_unit
         , cmd_flash_point_max
         , cmd_taxtable1
         , cmd_taxtable2
         , cmd_taxtable3
         , cmd_taxtable4
         , heirarchy_specificity
         )
         SELECT c.cmd_code
              , c.cmd_name
              , c.cmd_non_spec
              , c.cmd_flash_point
              , c.cmd_flash_unit
              , c.cmd_flash_point_max
              , c.cmd_taxtable1
              , c.cmd_taxtable2
              , c.cmd_taxtable3
              , c.cmd_taxtable4
              , MIN(10 - (CASE WHEN cl.billto   = @billto   THEN 5 ELSE 0 END)
                       - (CASE WHEN cl.revtype1 = @revtype1 THEN 1 ELSE 0 END)
                       - (CASE WHEN cl.revtype2 = @revtype2 THEN 1 ELSE 0 END)
                       - (CASE WHEN cl.revtype3 = @revtype3 THEN 1 ELSE 0 END)
                       - (CASE WHEN cl.revtype4 = @revtype4 THEN 1 ELSE 0 END)
                   ) AS heirarchy_specificity
           FROM commodity c
           JOIN commodity_linkto cl ON c.cmd_code = cl.cmd_code
          WHERE c.cmd_active = 'Y'
            AND (cl.billto   = @billto   OR (@billto_restricted = 'N' AND cl.billto = 'UNKNOWN'))
            AND (cl.revtype1 = @revtype1 OR cl.revtype1 = 'UNK')
            AND (cl.revtype2 = @revtype2 OR cl.revtype2 = 'UNK')
            AND (cl.revtype3 = @revtype3 OR cl.revtype3 = 'UNK')
            AND (cl.revtype4 = @revtype4 OR cl.revtype4 = 'UNK')
         GROUP BY c.cmd_code
                , c.cmd_name
                , c.cmd_non_spec
                , c.cmd_flash_point
                , c.cmd_flash_unit
                , c.cmd_flash_point_max
                , c.cmd_taxtable1
                , c.cmd_taxtable2
                , c.cmd_taxtable3
                , c.cmd_taxtable4
         --Retain only the most specific ones
         SELECT @heirarchy_specificity = MIN(heirarchy_specificity)
           FROM @temp
         DELETE FROM @temp
          WHERE heirarchy_specificity <> @heirarchy_specificity
      END

      --When now rows found
      IF (SELECT COUNT(1) FROM @temp) <= 0
      BEGIN
         --When not restricted to a billto then list all commodities else list only UNKNOWN
         IF @billto_restricted = 'N'
            BEGIN
               INSERT INTO @temp
               ( code
               , name
               , cmd_non_spec
               , cmd_flash_point
               , cmd_flash_unit
               , cmd_flash_point_max
               , cmd_taxtable1
               , cmd_taxtable2
               , cmd_taxtable3
               , cmd_taxtable4
               , heirarchy_specificity
               )
               SELECT cmd_code
                    , cmd_name
                    , cmd_non_spec
                    , cmd_flash_point
                    , cmd_flash_unit
                    , cmd_flash_point_max
                    , cmd_taxtable1
                    , cmd_taxtable2
                    , cmd_taxtable3
                    , cmd_taxtable4
                    , 99 AS heirarchy_specificity
                 FROM commodity
            END
         ELSE
            BEGIN
               INSERT INTO @temp
               ( code
               , name
               , cmd_non_spec
               , cmd_flash_point
               , cmd_flash_unit
               , cmd_flash_point_max
               , cmd_taxtable1
               , cmd_taxtable2
               , cmd_taxtable3
               , cmd_taxtable4
               , heirarchy_specificity
               )
               SELECT cmd_code
                    , cmd_name
                    , cmd_non_spec
                    , cmd_flash_point
                    , cmd_flash_unit
                    , cmd_flash_point_max
                    , cmd_taxtable1
                    , cmd_taxtable2
                    , cmd_taxtable3
                    , cmd_taxtable4
                    , 99 AS heirarchy_specificity
                 FROM commodity
                WHERE cmd_code = 'UNKNOWN'
            END
      END

   --Final Resultset   
   SELECT *
     FROM @temp
   ORDER BY code

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[d_load_cmdid_for_dddw_intelli_sp] TO [public]
GO
