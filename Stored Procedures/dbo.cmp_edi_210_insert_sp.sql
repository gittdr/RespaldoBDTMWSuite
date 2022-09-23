SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cmp_edi_210_insert_sp]
(@cmp_id varchar(8))

AS
SET NOCOUNT ON

DECLARE @DEFAULT CHAR(1)

Select @DEFAULT = 'N'
IF (SELECT isnull(gi_string3,'N') FROM generalinfo WHERE gi_name = 'EDI210AdvOutputSelection') = 'Y'
BEGIN
	Select @DEFAULT = 'Y'
END
IF (SELECT COUNT(1) FROM COMPANY WHERE cmp_id = @cmp_id)>0
BEGIN
IF @DEFAULT = 'Y'
BEGIN

		-- ORIGINAL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'LH' and ces_applyto_definition = 'LH') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'LH',
		'LH',
		'Freight Invoice',
		'Y'	,
		'N'	)
	
			-- ORIGINAL CREDIT
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'CRD' and ces_applyto_definition = 'LH') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'CRD',
		'LH',
		'Freight Credit',
		'N',
		'Y'	)	
	
			-- ORIGINAL REBILL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'RBIL' and ces_applyto_definition = 'LH') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'RBIL',
		'LH',
		'Freight Rebill',
		'Y',
		'N'		)
	
		-- SUPPLEMENTAL INVOICE
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'SUPL' and ces_applyto_definition = 'SUPL') = 0	
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'SUPL',
		'SUPL',
		'Supplemental Invoice',
		'Y',
		'N'	)
	
			-- SUPPLEMENTAL CREDIT
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'CRD' and ces_applyto_definition = 'SUPL') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'CRD',
		'SUPL',
		'Supplemental Credit',
		'N',
		'Y'	)	
	
		-- SUPPLEMENTAL REBILL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'RBIL' and ces_applyto_definition = 'SUPL') = 0		
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'RBIL',
		'SUPL',
		'Supplemental Rebill',
		'Y',
		'N'	)	
	
			-- MISC INVOICE
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'MISC' and ces_applyto_definition = 'MISC') = 0			
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'MISC',
		'MISC',
		'Misc Invoice',
		'Y',
		'N'	)
	
				-- MISC CREDIT
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'CRD' and ces_applyto_definition = 'MISC') = 0				
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'CRD',
		'MISC',
		'Misc Credit',
		'N',
		'Y'	)	
	
		-- SUPPLEMENTAL REBILL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'RBIL' and ces_applyto_definition = 'MISC') = 0		
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_print_flag,	
		ces_nooutput)
		VALUES
		(@cmp_id,
		'RBIL',
		'MISC',
		'Misc Rebill',
		'Y',
		'N'		)		
END

ELSE

BEGIN
		-- ORIGINAL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'LH' and ces_applyto_definition = 'LH') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'LH',
		'LH',
		'Freight Invoice',
		'N'	)
	
			-- ORIGINAL CREDIT
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'CRD' and ces_applyto_definition = 'LH') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'CRD',
		'LH',
		'Freight Credit',
		'N'	)	
	
			-- ORIGINAL REBILL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'RBIL' and ces_applyto_definition = 'LH') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'RBIL',
		'LH',
		'Freight Rebill',
		'N'	)
	
		-- SUPPLEMENTAL INVOICE
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'SUPL' and ces_applyto_definition = 'SUPL') = 0	
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'SUPL',
		'SUPL',
		'Supplemental Invoice',
		'N'	)
	
			-- SUPPLEMENTAL CREDIT
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'CRD' and ces_applyto_definition = 'SUPL') = 0
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'CRD',
		'SUPL',
		'Supplemental Credit',
		'N'	)	
	
		-- SUPPLEMENTAL REBILL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'RBIL' and ces_applyto_definition = 'SUPL') = 0		
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'RBIL',
		'SUPL',
		'Supplemental Rebill',
		'N'	)	
	
			-- MISC INVOICE
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'MISC' and ces_applyto_definition = 'MISC') = 0			
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'MISC',
		'MISC',
		'Misc Invoice',
		'N'	)
	
				-- MISC CREDIT
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'CRD' and ces_applyto_definition = 'MISC') = 0				
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'CRD',
		'MISC',
		'Misc Credit',
		'N'	)	
	
		-- SUPPLEMENTAL REBILL
		IF (SELECT COUNT(1) FROM 	cmp_edi_210_settings where cmp_id = @cmp_id and ces_definition = 'RBIL' and ces_applyto_definition = 'MISC') = 0		
		INSERT INTO cmp_edi_210_settings
		(cmp_id	, 			
		ces_definition ,
		ces_applyto_definition	,
		ces_name,
		ces_nooutput)
		VALUES
		(@cmp_id,
		'RBIL',
		'MISC',
		'Misc Rebill',
		'N'	)		
	
	
		
END
END




GO
GRANT EXECUTE ON  [dbo].[cmp_edi_210_insert_sp] TO [public]
GO
