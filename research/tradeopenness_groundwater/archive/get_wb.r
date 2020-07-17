library('wbstats')
library('WDI')

new_wb_cache <- wbcache()
new_wdi_cache <- WDIcache()

wbsearch('latitude',cache=new_wb_cache)
wbsearch('temperature',cache=new_wb_cache)
wbsearch('precipitation',cache=new_wb_cache)

WDIsearch('latitude',cache=new_wdi_cache)
WDIsearch('temperature',cache=new_wdi_cache)
WDIsearch('precipitation',cache=new_wdi_cache)
