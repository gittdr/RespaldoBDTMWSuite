SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_tariff_report_rate_info_sp    Script Date: 8/20/97 1:58:33 PM ******/
create 	procedure [dbo].[d_tariff_report_rate_info_sp]  @tariff_no int
AS 
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/07/2007.01 ? PTS40187 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

SELECT 
tariffheader.tar_rowbasis , 
tariffheader.tar_colbasis , 
tariffheader.tar_number tar_number , 
tariffheader.tar_description , 
tariffheader.cht_itemcode , 
tariffheader.tar_rate , 
tariffheader.tar_tarriffnumber , 
tariffrate.tra_rate , 
tariffrate.trc_number_row , 
tariffrate.trc_number_col , 
tariffrate.tar_number rate_tar_number , 
tariffrow.trc_sequence row_seq , 
tariffcolumn.trc_sequence col_seq , 
tariffrow.trc_matchvalue row_match , 
tariffcolumn.trc_matchvalue col_match , 
tariffrow.trc_rangevalue row_range , 
tariffcolumn.trc_rangevalue col_range , 
space(30) row_nmstct , 
space(30) col_nmstct 
INTO #temp 
FROM tariffrate  LEFT OUTER JOIN  tariffrowcolumn tariffrow  ON  tariffrate.trc_number_row  = tariffrow.trc_number   
			     LEFT OUTER JOIN  tariffrowcolumn tariffcolumn  ON  tariffrate.trc_number_col  = tariffcolumn.trc_number ,
	 tariffheader
WHERE ( tariffrate.tar_number = tariffheader.tar_number ) and 
 ( tariffheader.tar_number = @tariff_no ) and
 ( IsNull(tariffrate.tra_apply, '') = '' or tariffrate.tra_apply <> 'N') --DPH PTS 29877

/*if not exists ( SELECT tar_number FROM tariffrate WHERE tar_number = @tariff_no ) 
INSERT 
INTO #temp ( 
tar_rowbasis , 
tar_colbasis , 
tar_number , 
tar_description , 
cht_itemcode , 
tar_rate , 
tar_tarriffnumber ) 
SELECT 
tariffheader.tar_rowbasis , 
tariffheader.tar_colbasis , 
tariffheader.tar_number , 
tariffheader.tar_description , 
tariffheader.cht_itemcode , 
tariffheader.tar_rate , 
tariffheader.tar_tarriffnumber 
FROM tariffheader 
WHERE ( tariffheader.tar_number = @tariff_no ) 
*/

if exists ( SELECT tar_number FROM #temp WHERE tar_rowbasis in ('OCT','DCT' ) ) 
UPDATE #temp 
SET row_nmstct = city.cty_nmstct 
FROM city 
WHERE city.cty_code = convert ( int , #temp.row_match ) 

if exists ( SELECT tar_number FROM #temp WHERE tar_colbasis in ('OCT','DCT' ) ) 
UPDATE #temp 

SET col_nmstct = city.cty_nmstct 
FROM city 
WHERE city.cty_code = convert ( int , #temp.col_match ) 

SELECT * FROM #temp 


GO
GRANT EXECUTE ON  [dbo].[d_tariff_report_rate_info_sp] TO [public]
GO
