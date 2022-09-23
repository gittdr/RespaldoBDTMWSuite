SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollDedicatedBillsView] AS
/*******************************************************************************************************************  
  Object Description:
  This query retrieves dedicated bills in HLD status

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  -----------------------------------------------------------------------
  2017/10/23   AVANE            NSUITE-202679  Initial Version
********************************************************************************************************************/
SELECT
  [dedbill].[DedicatedBillId],
  [dedbill].[DedicatedTypeId],
  [dedbill].[DedicatedStatusId],
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
GO
GRANT DELETE ON  [dbo].[TMWScrollDedicatedBillsView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollDedicatedBillsView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollDedicatedBillsView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollDedicatedBillsView] TO [public]
GO
