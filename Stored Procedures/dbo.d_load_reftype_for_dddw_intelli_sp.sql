SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_load_reftype_for_dddw_intelli_sp] 
( @billto   VARCHAR(8)
, @revtype1 VARCHAR(6)
, @revtype2 VARCHAR(6)
, @revtype3 VARCHAR(6)
, @revtype4 VARCHAR(6)
) AS 
/**
 *
 * NAME:
 * dbo.d_load_reftype_for_dddw_intelli_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Stored Procedure used as a data source for datawindow d_load_reftype_for_dddw_intelli
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
   ( abbr                  VARCHAR(6)  NULL
   , name                  VARCHAR(20) NULL
   , code                  INT         NULL
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
         IF (SELECT COUNT(1) FROM reftype_linkto WHERE billto = @billto) <= 0
            SELECT @billto_restricted = 'N'
   END

   --Find all ref types matching one/more arguments and determine specificity
   IF NOT ( @billto   = 'UNKNOWN' AND
            @revtype1 = 'UNK' AND
            @revtype2 = 'UNK' AND
            @revtype3 = 'UNK' AND
            @revtype4 = 'UNK'
          )
      BEGIN
         
         INSERT INTO @temp
         ( abbr
         , name
         , code
         , heirarchy_specificity
         )
         SELECT l.abbr
              , l.name
              , l.code
              , MIN(10 - (CASE WHEN rl.billto   = @billto   THEN 5 ELSE 0 END)
                       - (CASE WHEN rl.revtype1 = @revtype1 THEN 1 ELSE 0 END)
                       - (CASE WHEN rl.revtype2 = @revtype2 THEN 1 ELSE 0 END)
                       - (CASE WHEN rl.revtype3 = @revtype3 THEN 1 ELSE 0 END)
                       - (CASE WHEN rl.revtype4 = @revtype4 THEN 1 ELSE 0 END)
                   ) AS heirarchy_specificity
           FROM (SELECT abbr
                      , name
                      , code
                   FROM labelfile
                  WHERE labeldefinition = 'ReferenceNumbers'
                    AND IsNull(retired, 'N') <> 'Y'
                ) l
           JOIN reftype_linkto rl ON l.abbr = rl.ref_type
          WHERE (rl.billto   = @billto   OR (@billto_restricted = 'N' AND rl.billto = 'UNKNOWN'))
            AND (rl.revtype1 = @revtype1 OR rl.revtype1 = 'UNK')
            AND (rl.revtype2 = @revtype2 OR rl.revtype2 = 'UNK')
            AND (rl.revtype3 = @revtype3 OR rl.revtype3 = 'UNK')
            AND (rl.revtype4 = @revtype4 OR rl.revtype4 = 'UNK')
         GROUP BY l.abbr
                , l.name
                , l.code
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
               ( abbr
               , name
               , code
               , heirarchy_specificity
               )
               SELECT abbr
                    , name
                    , code
                    , 99 AS heirarchy_specificity
                 FROM labelfile
                WHERE labeldefinition = 'ReferenceNumbers'
                  AND IsNull(retired, 'N') <> 'Y'
            END
         ELSE
            BEGIN
               INSERT INTO @temp
               ( abbr
               , name
               , code
               , heirarchy_specificity
               )
               SELECT abbr
                    , name
                    , code
                    , 99 AS heirarchy_specificity
                 FROM labelfile
                WHERE labeldefinition = 'ReferenceNumbers'
                  AND abbr = 'UNK'
            END
      END

   --Final Resultset   
   SELECT *
     FROM @temp
   ORDER BY name

   RETURN

END
GO
GRANT EXECUTE ON  [dbo].[d_load_reftype_for_dddw_intelli_sp] TO [public]
GO
