SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  This procedure will build views for each "form" in Mobile Connect.
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  05/02/2016   Mark Fielder     PTS:         Initial Release
  05/04/2016   Lisa Bohm        PTS:         Rewrote to remove as much processing from nested loops as possible.
********************************************************************************************************************/


CREATE PROCEDURE [dbo].[MobileCommMessageDefinitionCreateViews](@MessageDefinitionId INT
, @debug BIT = 0)

AS
BEGIN

SET NOCOUNT ON;

DECLARE
  @Properties TABLE
(NodeDefinitionId       INT NOT NULL
, messageDefinitionId    INT NOT NULL
, PropertyDefinitionId   INT NOT NULL
, MCNPDname              VARCHAR(200)
, cleanName              VARCHAR(200) NOT NULL
, DataTypeId             INT NOT NULL
, baseName               VARCHAR(200) NOT NULL
, nodeName               VARCHAR(200) NOT NULL
, parentNodeDefinitionID INT
, SQLDataType            VARCHAR(15) NOT NULL
);

DECLARE
  @viewName    VARCHAR(200)
, @viewSQL     VARCHAR(MAX)
, @viewColumns VARCHAR(MAX)
, @viewJoins   VARCHAR(MAX)
, @nodeJoins   VARCHAR(MAX);

INSERT INTO @Properties
(NodeDefinitionId
, messageDefinitionId
, PropertyDefinitionId
, MCNPDname
, cleanName
, DataTypeId
, baseName
, nodeName
, parentNodeDefinitionID
, SQLDataType
)
       SELECT a.NodeDefinitionID
            , a.messageDefinitionID
            , b.PropertyDefinitionID
            , b.[Name] AS MCNPDname
            , REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(b.Name, ' ', ''), '?', ''), '#', ''), '(', ''), ')', ''), '-', ''), ':', ''), '-', ''), '\', '_') AS cleanName
            , b.DatatypeId
            , 'FormData_'+REPLACE(c.ExternalId, ' ', '')+'_'+REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(c.Name, ' ', ''), '?', ''), '#', ''), '(', ''), ')', ''), '-', ''), '\', '_') AS baseName
            , CASE
                  WHEN a.[Name] = c.[Name]
                  THEN 'Header'
                  ELSE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(a.name, ' ', ''), '?', ''), '#', ''), '(', ''), ')', ''), '-', ''), '\', '_')
              END AS nodeName
            , a.ParentNodeDefinitionId
            , 'varchar(200)' -- hard code to varchar
			/*CASE b.DatatypeID
                  WHEN 1
                  THEN 'int'
                  WHEN 2
                  THEN 'decimal(12,4)'
                  WHEN 4
                  THEN 'datetime'  --skip dates for now PNet auto fields have GMT in the dates
                  WHEN 7
                  THEN 'date'
                  WHEN 8
                  THEN 'time'
                  ELSE 'varchar(200)'
              END*/
       FROM mobilecommmessagenodedefinition a
            INNER JOIN mobilecommmessagenodepropertydefinition b ON a.NodeDefinitionId = b.NodeDefinitionId
            INNER JOIN MobileCommMessageDefinition c ON a.messagedefinitionID = c.messagedefinitionID
       WHERE a.MessageDefinitionId = @MessageDefinitionId;

DECLARE
  @NodeDefinitionId INT;

IF @debug = 1
    BEGIN
        SELECT NodeDefinitionId
             , messageDefinitionId
             , PropertyDefinitionId
             , MCNPDname
             , cleanName
             , DataTypeId
             , baseName
             , nodeName
             , parentNodeDefinitionID
             , SQLDataType
        FROM @Properties;

    END;

DECLARE buildMCView CURSOR FAST_FORWARD READ_ONLY
FOR SELECT DISTINCT
           NodeDefinitionId
    FROM @Properties;

OPEN buildMCView;

FETCH NEXT FROM buildMCView INTO
  @NodeDefinitionId;

WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @viewname = 
               basename+'_'+ISNULL(nodeName, 'Header')
        FROM @properties
        WHERE NodeDefinitionId = @NodeDefinitionId;

        IF @debug = 0
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM INFORMATION_SCHEMA.VIEWS
                    WHERE TABLE_NAME = @viewName
                )
                    EXECUTE ('drop view '+@viewName);
            END;
		SET @viewColumns = '';
		SET @viewJoins = '';
		SET @nodeJoins = '';

		SELECT @viewColumns = @viewColumns+CASE
											   WHEN @viewColumns <> ''
											   THEN ', '
											   ELSE ''
										   END
													+'convert('+SQLDataType
													+', data'
													+CONVERT( VARCHAR(10), ROW_NUMBER() OVER(ORDER BY PropertyDefinitionId))+'.Value) as '
													+'['+CleanName+']'
		FROM @Properties
		WHERE NodeDefinitionId = @NodeDefinitionId;

		SELECT @viewJoins = @viewJoins+CASE
										   WHEN @viewJoins <> ''
										   THEN ' '
										   ELSE ''
									   END
													+'LEFT OUTER JOIN MobileCommMessageNodeProperty data'
													+ CONVERT( VARCHAR(10), ROW_NUMBER() OVER(ORDER BY PropertyDefinitionId))
													+' on data'
													+CONVERT(VARCHAR(10), ROW_NUMBER() OVER(ORDER BY PropertyDefinitionId))
													+'.NodeContentId = Node'
													+CONVERT(VARCHAR(100), @NodeDefinitionId)
													+'.NodeContentId AND data'
													+CONVERT(VARCHAR(10), ROW_NUMBER() OVER(ORDER BY PropertyDefinitionId))+'.PropertyDefinitionId = '
													+CONVERT(VARCHAR(100), PropertyDefinitionId)
		FROM @properties
		WHERE NodeDefinitionId = @NodeDefinitionId;

		--node joins
		--					join MobileCommMessageContentNode as RootNode on  RootNode.MessageId = MobileCommMessageContent.MessageId
		--					join MobileCommMessageContentNode on  MobileCommMessageContentNode.MessageId = MobileCommMessageContent.MessageId and MobileCommMessageContentNode.ParentNodeContentId = RootNode.NodeContentId
		declare @currentNode int
		select @currentNode = @NodeDefinitionId
		while @currentNode is not null
		begin
			declare @parentNode int
			select @parentNode = ParentNodeDefinitionId  
 			from MobileCommMessageNodeDefinition
			where NodeDefinitionId = @currentNode

			select @nodeJoins = ' join MobileCommMessageNode as Node' + convert(varchar(100), @currentNode) + ' on Node' + convert(varchar(100), @currentNode) + '.MessageId = MobileCommMessage.MessageId and Node' +
							convert(varchar(100), @currentNode) + '.ParentNodeContentId' +
							case when @parentNode is null then 
							' is null '
							else ' = Node' + convert(varchar(100), @parentNode) + '.NodeContentId'  end + @nodeJoins 
	
			select @currentNode = @parentNode
		end

		SELECT @viewSQL = 'CREATE VIEW '
										+@viewName
										+' AS SELECT Node'
										+CONVERT( VARCHAR(100), NodeDefinitionId)
										+'.MessageId, '
										+CASE
												WHEN ParentNodeDefinitionId IS NULL
												THEN 'MobileCommMessage.DirectionId,'
												ELSE 'Node'
														+CONVERT(VARCHAR(100), NodeDefinitionId)
														+'.ParentNodeContentId,'
										END
										+' Node'
										+CONVERT(VARCHAR(100), NodeDefinitionId)
										+'.NodeContentId, '
										+@viewColumns
										+'  FROM MobileCommMessage '
										+@nodeJoins
										+'  '
										+@viewJoins
										+' WHERE MobileCommMessage.MessageDefinitionId = '
										+ CONVERT(VARCHAR(100), MessageDefinitionId)
										+' AND Node'
										+ CONVERT(VARCHAR(100), NodeDefinitionId)
										+'.NodeDefinitionId = '
										+CONVERT(VARCHAR(100), NodeDefinitionId)+'  '
		FROM @properties
		WHERE NodeDefinitionId = @NodeDefinitionId;
		IF @debug = 0
		BEGIN
			EXECUTE (@viewSQL);
		END
		ELSE
		BEGIN

			SELECT @NodeDefinitionId AS NodeDefnID
					, @viewname AS ViewNm 
					, @viewColumns AS viewCols
					, @viewJoins AS viewJns
					, @nodeJoins AS nodeJns;


			PRINT @viewSQL;
		END;

        FETCH NEXT FROM buildMCView INTO
          @NodeDefinitionId;
    END;

CLOSE buildMCView;
DEALLOCATE buildMCView;

END
GO
GRANT EXECUTE ON  [dbo].[MobileCommMessageDefinitionCreateViews] TO [public]
GO
