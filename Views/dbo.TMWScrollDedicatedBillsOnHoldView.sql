SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollDedicatedBillsOnHoldView] AS
/*******************************************************************************************************************  
  Object Description:
  This query retrieves dedicated bills in HLD status

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  -----------------------------------------------------------------------
  2017/08/18   AVANE            NSUITE-200346  Initial Version
********************************************************************************************************************/
SELECT
  [dedbill].[DedicatedBillId],
  [dm].[BillNumber],
  [ds].[Name] AS [BillStatus],
  [dt].[Name] AS [BillType],
  [dedbill].[BillDate],
  [dm].[BillToId],
  [billToCompany].[cmp_name] AS [BillToName],
  [dc].[ContractId],
  [dc].[Description] AS [ContractDescription]
FROM DedicatedBill dedbill (NOLOCK)
  JOIN DedicatedMaster dm (NOLOCK) ON ([dedbill].[DedicatedMasterId] = [dm].[DedicatedMasterId])
  JOIN DedicatedType dt (NOLOCK) ON ([dedbill].[DedicatedTypeId] = [dt].[DedicatedTypeId])
  JOIN DedicatedStatus ds (NOLOCK) ON ([dedbill].[DedicatedStatusId] = [ds].[DedicatedStatusId])
  JOIN DedicatedContract dc (NOLOCK) ON ([dm].[ContractId] = [dc].[ContractId])
  LEFT JOIN company billToCompany (NOLOCK) ON ([dm].[BillToId] = [billToCompany].[cmp_id]) 
WHERE [ds].[DedicatedStatusId] = 1 -- "On Hold"
GO
GRANT DELETE ON  [dbo].[TMWScrollDedicatedBillsOnHoldView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollDedicatedBillsOnHoldView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollDedicatedBillsOnHoldView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollDedicatedBillsOnHoldView] TO [public]
GO
