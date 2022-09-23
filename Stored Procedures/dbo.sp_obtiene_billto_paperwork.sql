SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Procedimiento para obtener los documentos requeridos por cliente

--exec sp_obtiene_billto_paperwork

create  PROCEDURE [dbo].[sp_obtiene_billto_paperwork] @BillTo varchar(13)
AS


SET NOCOUNT ON

	BEGIN 
		SELECT        Bdt.cmp_id AS Billto, Bdt.bdt_doctype AS Documento, lab.name AS Nombre, CASE bdt_required_for_application WHEN 'B' THEN 'Fact y Liq' WHEN 'I' THEN 'Facturacion' ELSE 'Liquidaciones' END AS RequeridoPor, 
                         dbo.company.cmp_name
FROM            dbo.BillDoctypes AS Bdt INNER JOIN
                         dbo.company ON Bdt.cmp_id = dbo.company.cmp_id LEFT OUTER JOIN
                         dbo.labelfile AS lab ON lab.abbr = Bdt.bdt_doctype AND lab.labeldefinition = 'Paperwork' AND ISNULL(lab.retired, 'N') <> 'Y' AND Bdt.bdt_inv_required = 'Y'
WHERE        (dbo.company.cmp_active = 'Y') and (Bdt.cmp_id = @BillTo or 'TODAS' = @BillTo)
		END 





GO
