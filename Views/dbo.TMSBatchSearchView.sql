SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[TMSBatchSearchView] 
AS

SELECT b.BatchId, b.BatchStatus, b.BatchType, b.CreateDate, b.CreateUser, b.FileName, b.ImpId, b.ProcessedData, i.Name, i.ImportType, COUNT(bm.BatchId) as 'ErrorCount'
FROM TMSBatch b 
LEFT JOIN TMSBatchMessages bm ON bm.BatchId = b.BatchId AND bm.HasError = 'Y' AND RowType IN ('S','M')
LEFT JOIN TMSImportConfig i ON b.ImpId = i.ImpId 
GROUP BY b.BatchId, b.BatchStatus, b.BatchType, b.CreateDate, b.CreateUser, b.FileName, b.ImpId, b.ProcessedData, i.Name, i.ImportType
GO
GRANT SELECT ON  [dbo].[TMSBatchSearchView] TO [public]
GO
