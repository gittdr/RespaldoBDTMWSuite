SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_Liverpool_OPO]
as
begin

UPDATE referencenumber
SET REF_NUMBER = 'OPO'
WHERE  REF_NUMBER LIKE 'OPO%' AND REF_NUMBER <> 'OPO'

end
GO
