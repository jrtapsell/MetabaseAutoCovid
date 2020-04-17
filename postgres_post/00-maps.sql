\c :meta_db;

INSERT INTO public.setting VALUES ('custom-geojson', 
'{
    "8a647059-3aad-4ee1-33e2-84c92c035317":{
        "name":"Countries",
        "url":"http://localhost:3000/nginx_mirror/countries.geojson",
        "region_key":"ctry19cd",
        "region_name":"ctry19nm"
    },"14738f8c-458f-2060-8bbc-591b3cf4a669":{
        "name":"Regions",
        "url":"http://localhost:3000/nginx_mirror/regions.geojson",
        "region_key":"rgn18cd",
        "region_name":"rgn18nm"
    },"f3500aab-534a-46ba-0501-b0adc587552c":{
        "name":"UTLAs",
        "url":"http://localhost:3000/nginx_mirror/utlas.geojson",
        "region_key":"ctyua19cd",
        "region_name":"ctyua19nm"
    }
}');