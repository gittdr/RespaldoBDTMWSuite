SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GetFormVwFlds_SelectedVw_VwFlds]
	@FormSN int

AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT sv.Sequence, fvf.ViewFieldSN, vf.FieldName,
vf.IsRepeating, vf.Required, vf.BusinessRule, vf.BusinessRuleType,
vf.DefaultLength, vf.DefaultType, vf.DisplayedFieldName, vf.DispXfcTag, vf.ClearWhenFinished
FROM tblFormViewFields fvf
INNER JOIN tblSelectedViews sv ON fvf.SelectedViewsSN = sv.SN
INNER JOIN tblViewFields vf ON fvf.ViewFieldSN = vf.SN
WHERE fvf.FormFieldSN = @FormSN
ORDER BY 1, 10, vf.SN

GO
GRANT EXECUTE ON  [dbo].[tm_GetFormVwFlds_SelectedVw_VwFlds] TO [public]
GO
