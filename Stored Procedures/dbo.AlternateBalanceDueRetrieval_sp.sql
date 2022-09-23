SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[AlternateBalanceDueRetrieval_sp] (
				@ivh_invoicenumber	varchar(12), 
				@invoice_list		varchar(1024) OUT,
				@ShowBalanceDue		char(1) OUT
			)
AS
	DECLARE @ivh_applyto varchar(12)	
	DECLARE @ivh_hdrnumber int
	DECLARE @ivh_hdrnumber_newest int
	DECLARE	@invoice_include varchar(12)
	DECLARE @ivh_applyto_definition varchar(6)
	DECLARE @ord_hdrnumber int

	SELECT	@ivh_hdrnumber = ivh_hdrnumber,
			@ivh_applyto = ivh_applyto,
			@ivh_applyto_definition = ivh_applyto_definition,
			@ord_hdrnumber = ord_hdrnumber
	FROM	invoiceheader
	WHERE	ivh_invoicenumber = @ivh_invoicenumber 
	
	--SELECT '@ivh_hdrnumber', @ivh_hdrnumber
	--SELECT '@ivh_applyto', @ivh_applyto
	--SELECT '@ivh_applyto_definition',@ivh_applyto_definition
	--SELECT '@ord_hdrnumber',@ord_hdrnumber
	
	IF @ivh_hdrnumber IS NULL BEGIN
		SELECT @invoice_list = ''
		SELECT @ShowBalanceDue = 'N'
	END
	ELSE BEGIN
		IF @ivh_applyto_definition = 'SUPL' BEGIN
			--Just return all supplemental
			DECLARE InvoiceList CURSOR FAST_FORWARD FOR
				SELECT	ivh_invoicenumber
				FROM	invoiceheader
				WHERE	ord_hdrnumber = @ord_hdrnumber
						AND ivh_applyto_definition = 'SUPL'

			OPEN InvoiceList

			FETCH NEXT FROM InvoiceList 
			 INTO @invoice_include

			SELECT @invoice_list = ''
			SELECT @invoice_list = ',' + @ivh_invoicenumber
			
			WHILE @@Fetch_status = 0
			BEGIN
				IF @invoice_include <> @ivh_invoicenumber BEGIN
					SELECT @invoice_list = @invoice_list + ',' + @invoice_include 
				END

				FETCH NEXT FROM InvoiceList
				INTO @invoice_include
			END
			IF LEN(@invoice_list) > 0 BEGIN
				SELECT @invoice_list = @invoice_list + ','
			END 

			CLOSE InvoiceList
			DEALLOCATE InvoiceList

			SELECT	@ivh_hdrnumber_newest = MAX(ivh.ivh_hdrnumber)
			FROM	invoiceheader ivh
			WHERE	CHARINDEX(',' + ivh.ivh_invoicenumber + ',', @invoice_list) > 0
			
			SELECT @ShowBalanceDue = 'N'
			
			
			IF ((@ivh_hdrnumber_newest = @ivh_hdrnumber) AND (@ivh_hdrnumber > 0)) BEGIN
				SELECT @ShowBalanceDue = 'Y'
			END
			
		END
		ELSE BEGIN
			DECLARE InvoiceList CURSOR FAST_FORWARD FOR
				SELECT	ivh_invoicenumber
				FROM	invoiceheader
				WHERE	ord_hdrnumber = @ord_hdrnumber
						AND ivh_applyto_definition <> 'SUPL'

			OPEN InvoiceList

			FETCH NEXT FROM InvoiceList 
			 INTO @invoice_include

			SELECT @invoice_list = ''
			SELECT @invoice_list = ',' + @ivh_invoicenumber
			
			WHILE @@Fetch_status = 0
			BEGIN
				IF @invoice_include <> @ivh_invoicenumber BEGIN
					SELECT @invoice_list = @invoice_list + ',' + @invoice_include 
				END

				FETCH NEXT FROM InvoiceList
				INTO @invoice_include
			END
			IF LEN(@invoice_list) > 0 BEGIN
				SELECT @invoice_list = @invoice_list + ','
			END 

			CLOSE InvoiceList
			DEALLOCATE InvoiceList

			SELECT	@ivh_hdrnumber_newest = MAX(ivh.ivh_hdrnumber)
			FROM	invoiceheader ivh
			WHERE	CHARINDEX(',' + ivh.ivh_invoicenumber + ',', @invoice_list) > 0
			
			SELECT @ShowBalanceDue = 'N'
			
			
			IF ((@ivh_hdrnumber_newest = @ivh_hdrnumber) AND (@ivh_hdrnumber > 0)) BEGIN
				SELECT @ShowBalanceDue = 'Y'
			END
		END
	END
GO
GRANT EXECUTE ON  [dbo].[AlternateBalanceDueRetrieval_sp] TO [public]
GO
