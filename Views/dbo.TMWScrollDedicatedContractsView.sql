SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollDedicatedContractsView] AS
/*******************************************************************************************************************  
  Object Description:
  This query retrieves dedicated contracts

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  -----------------------------------------------------------------------
  2017/08/15   AVANE            NSUITE-200346  Initial Version
********************************************************************************************************************/
WITH labelfileNames ([labeldefinition], [abbr], [name])
AS 
(
  SELECT [labeldefinition], [abbr], [name]
  FROM labelfile (NOLOCK)
  WHERE labeldefinition IN ('REVTYPE1', 'REVTYPE2', 'REVTYPE3', 'REVTYPE4')
)
SELECT
  [dc].[ContractId],
  [dc].[BillToId],
  [billToCompany].[cmp_name] AS [BillToName],
  [dc].[Description],
  [dc].[ContractStart],
  [dc].[ContractEnd],
  [revType1Restrict].[Value] AS [RevType1],
  (SELECT lf.name FROM labelfileNames lf (NOLOCK) WHERE lf.labeldefinition = 'RevType1' AND lf.abbr = revType1Restrict.[Value]) AS [RevType1Name],
  [revType2Restrict].[Value] AS [RevType2],
  (SELECT lf.name FROM labelfileNames lf (NOLOCK) WHERE lf.labeldefinition = 'RevType2' AND lf.abbr = revType2Restrict.[Value]) AS [RevType2Name],
  [revType3Restrict].[Value] AS [RevType3],
  (SELECT lf.name FROM labelfileNames lf (NOLOCK) WHERE lf.labeldefinition = 'RevType3' AND lf.abbr = revType3Restrict.[Value]) AS [RevType3Name],
  [revType4Restrict].[Value] AS [RevType4],
  (SELECT lf.name FROM labelfileNames lf (NOLOCK) WHERE lf.labeldefinition = 'RevType4' AND lf.abbr = revType4Restrict.[Value]) AS [RevType4Name]
FROM DedicatedContract dc (NOLOCK)
  LEFT JOIN company billToCompany (NOLOCK) ON ([dc].[BillToId] = [billToCompany].[cmp_id]) 
  LEFT JOIN DedicatedContractRestriction revType1Restrict (NOLOCK) ON ([dc].[ContractId] = [revType1Restrict].[ContractId] AND [revType1Restrict].[LabelDefinition] = 'RevType1')
  LEFT JOIN DedicatedContractRestriction revType2Restrict (NOLOCK) ON ([dc].[ContractId] = [revType2Restrict].[ContractId] AND [revType2Restrict].[LabelDefinition] = 'RevType2')
  LEFT JOIN DedicatedContractRestriction revType3Restrict (NOLOCK) ON ([dc].[ContractId] = [revType3Restrict].[ContractId] AND [revType3Restrict].[LabelDefinition] = 'RevType3')
  LEFT JOIN DedicatedContractRestriction revType4Restrict (NOLOCK) ON ([dc].[ContractId] = [revType4Restrict].[ContractId] AND [revType4Restrict].[LabelDefinition] = 'RevType4')
GO
GRANT DELETE ON  [dbo].[TMWScrollDedicatedContractsView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollDedicatedContractsView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollDedicatedContractsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollDedicatedContractsView] TO [public]
GO
