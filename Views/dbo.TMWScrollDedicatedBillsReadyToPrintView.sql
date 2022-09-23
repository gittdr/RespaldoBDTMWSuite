SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[TMWScrollDedicatedBillsReadyToPrintView] AS
/*******************************************************************************************************************  
  Object Description:
  This query retrieves dedicated bills in Redy to Print (RTP) status

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ---------------------------------------------------------------------
  2017/08/21   GTEJWANI         NSUITE-202053  Initial Version
********************************************************************************************************************/
SELECT
  [dedicatedBill].[DedicatedBillId],
  [dedicatedMaster].[BillNumber],
  [dedicatedStatus].[Name] AS [BillStatus],
  [dedicatedType].[Name] AS [BillType],
  [dedicatedBill].[BillDate],
  [dedicatedMaster].[BillToId],
  [billToCompany].[cmp_name] AS [BillToName],
  [dedicatedContract].[ContractId],
  [dedicatedContract].[Description] AS [ContractDescription]
FROM DedicatedBill dedicatedBill (NOLOCK)
  JOIN DedicatedMaster dedicatedMaster (NOLOCK) ON ([dedicatedBill].[DedicatedMasterId] = [dedicatedMaster].[DedicatedMasterId])
  JOIN DedicatedType dedicatedType (NOLOCK) ON ([dedicatedBill].[DedicatedTypeId] = [dedicatedType].[DedicatedTypeId])
  JOIN DedicatedStatus dedicatedStatus (NOLOCK) ON ([dedicatedBill].[DedicatedStatusId] = [dedicatedStatus].[DedicatedStatusId])
  JOIN DedicatedContract dedicatedContract (NOLOCK) ON ([dedicatedMaster].[ContractId] = [dedicatedContract].[ContractId])
  LEFT JOIN company billToCompany (NOLOCK) ON ([dedicatedMaster].[BillToId] = [billToCompany].[cmp_id]) 
WHERE [dedicatedStatus].[DedicatedStatusId] = 3 -- Retrieve RTP status 
GO
GRANT DELETE ON  [dbo].[TMWScrollDedicatedBillsReadyToPrintView] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWScrollDedicatedBillsReadyToPrintView] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWScrollDedicatedBillsReadyToPrintView] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWScrollDedicatedBillsReadyToPrintView] TO [public]
GO
