SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[quitanulosinv] as

update invoiceheader set ivh_ref_Number = '**' where ivh_ref_number is null

GO
