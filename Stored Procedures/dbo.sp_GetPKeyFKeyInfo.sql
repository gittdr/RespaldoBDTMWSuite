SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetPKeyFKeyInfo]
( @ParentTable VARCHAR(128)
) AS

/**
 *
 * NAME:
 * dbo.sp_GetPKeyFKeyInfo
 *
 * TYPE:
 * Stored proc
 *
 * DESCRIPTION:
 * Returns Foreign Key Referential Integrity Info for a given Table
 *
 * RETURNS:
 * NA
 *
 * RESULT SETS:
 * PKeyTable
 * FKeyName
 * FKeyTable
 * FKeyTable_LogicalName
 * FKeyColumnSeqNo
 * FKeyColumnName
 * OnDeleteAction
 * OnUpdateAction
 *
 *
 * PARAMETERS:
 * 001 - @ParentTable VARCHAR(128)
 *
 * REVISION HISTORY:
 * 04/13/12 SPN PTS62240 - Initial Version created
 *
 **/

SET NOCOUNT ON

BEGIN

   DECLARE @temp TABLE
   ( PKeyTable             VARCHAR(128)
   , FKeyName              VARCHAR(128)
   , FKeyTable             VARCHAR(128)
   , FKeyTable_LogicalName VARCHAR(128)
   , FKeyColumnSeqNo       INT
   , FKeyColumnName        VARCHAR(128)
   , OnDeleteAction        VARCHAR(60)
   , OnUpdateAction        VARCHAR(60)
   )

   INSERT INTO @temp
   ( PKeyTable
   , FKeyName
   , FKeyTable
   , FKeyTable_LogicalName
   , FKeyColumnSeqNo
   , FKeyColumnName
   , OnDeleteAction
   , OnUpdateAction
   )
   SELECT OBJECT_NAME (f.referenced_object_id)                       AS PKeyTable
        , f.name                                                     AS FKeyName
        , OBJECT_NAME(f.parent_object_id)                            AS FKeyTable
        , OBJECT_NAME(f.parent_object_id)                            AS FKeyTable_LogicalName
        , fc.constraint_column_id                                    AS FKeyColumnSeqNo
        , COL_NAME(fc.parent_object_id,fc.parent_column_id)          AS FKeyColumnName
        , f.delete_referential_action_desc                           AS OnDeleteAction
        , f.update_referential_action_desc                           AS OnUpdateAction
     FROM sys.foreign_keys AS f
     JOIN sys.foreign_key_columns AS fc ON f.OBJECT_ID = fc.constraint_object_id
    WHERE OBJECT_NAME (f.referenced_object_id) = @ParentTable

   UPDATE @temp
      SET FKeyTable_LogicalName = doi.Object_LogicalName
     FROM @temp t
     JOIN dbObjectInfo doi ON t.FKeyTable = doi.Object_PhysicalName AND doi.Object_Type = 'TABLE'

   SELECT *
     FROM @temp

END
GO
GRANT EXECUTE ON  [dbo].[sp_GetPKeyFKeyInfo] TO [public]
GO
