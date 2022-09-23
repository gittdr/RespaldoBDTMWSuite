SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/****** Object:  Stored Procedure dbo.d_tar_rpt_rate_info_stl_sp    Script Date: 4/5/99 2:36:01 PM ******/
CREATE PROC [dbo].[d_tar_rpt_rate_info_stl_sp]
	@tariff_no int 
AS 

--	LOR	PTS# 50374	old proc, but was missing from VSS and had *=

SELECT 
		tariffheaderstl.tar_rowbasis , 
		tariffheaderstl.tar_colbasis , 
		tariffheaderstl.tar_number tar_number , 
		tariffheaderstl.tar_description , 
		tariffheaderstl.cht_itemcode , 
		tariffheaderstl.tar_rate , 
		tariffheaderstl.tar_tarriffnumber , 
		tariffratestl.tra_rate , 
		tariffratestl.trc_number_row , 
		tariffratestl.trc_number_col , 
		tariffratestl.tar_number rate_tar_number , 
		tariffrow.trc_sequence row_seq , 
		tariffcolumn.trc_sequence col_seq , 
		tariffrow.trc_matchvalue row_match , 
		tariffcolumn.trc_matchvalue col_match , 
		tariffrow.trc_rangevalue row_range , 
		tariffcolumn.trc_rangevalue col_range , 
		space(30) row_nmstct , 
		space(30) col_nmstct 
INTO #temp 
FROM tariffratestl  LEFT OUTER JOIN  tariffrowcolumnstl tariffrow  ON  tariffratestl.trc_number_row  = tariffrow.trc_number   
					LEFT OUTER JOIN  tariffrowcolumnstl tariffcolumn  ON  tariffratestl.trc_number_col  = tariffcolumn.trc_number ,
	 tariffheaderstl
WHERE ( tariffratestl.tar_number = tariffheaderstl.tar_number ) and 
 ( tariffheaderstl.tar_number = @tariff_no ) 
	 
/*	FROM tariffheaderstl , 
			tariffratestl , 
			tariffrowcolumnstl tariffrow , 
			tariffrowcolumnstl tariffcolumn 
	WHERE ( tariffratestl.trc_number_row *= tariffrow.trc_number ) and 
			( tariffratestl.trc_number_col *= tariffcolumn.trc_number ) and 
			( tariffratestl.tar_number = tariffheaderstl.tar_number ) and 
			( tariffheaderstl.tar_number = @tariff_no ) 
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
GRANT EXECUTE ON  [dbo].[d_tar_rpt_rate_info_stl_sp] TO [public]
GO
