SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[tblHRAggMsgGrpPerformance]
AS
SELECT MsgGrpAggPerfNum,
  BaseMsgSN,
  MsgCount,
  Start,
  Final,
  Convert(TIME, Cast((ToVendorRAW) AS DATETIME)) ToVendor,
  Convert(TIME, Cast((TotalRAW) AS DATETIME)) Total
FROM tblAggMsgGrpPerformance
GO
GRANT DELETE ON  [dbo].[tblHRAggMsgGrpPerformance] TO [public]
GO
GRANT INSERT ON  [dbo].[tblHRAggMsgGrpPerformance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblHRAggMsgGrpPerformance] TO [public]
GO
GRANT SELECT ON  [dbo].[tblHRAggMsgGrpPerformance] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblHRAggMsgGrpPerformance] TO [public]
GO
