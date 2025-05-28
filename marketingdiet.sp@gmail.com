<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>페이지 뷰어</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            height: 100%;
            overflow: hidden;
        }

        #pageViewer {
            width: 100vw;
            height: 100vh;
            border: none;
        }

        .loading {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-family: Arial, sans-serif;
            font-size: 18px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="loading" id="loading">페이지를 불러오는 중...</div>
    <iframe id="pageViewer" style="display: none;" 
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
            allowfullscreen></iframe>

    <script>
        async function loadPage() {
            try {
                const timestamp = Date.now() + Math.random();
                const response = await fetch(`./data.json?nocache=${timestamp}&t=${Date.now()}`, {
                    cache: 'no-cache',
                    headers: {
                        'Cache-Control': 'no-cache',
                        'Pragma': 'no-cache'
                    }
                });
                const text = await response.text();
                
                // JSON에서 URL 추출
                const match = text.match(/"url":\s*"([^"]+)"/);
                
                if (match) {
                    let url = match[1];
                    
                    // YouTube URL 변환
                    if (url.includes('youtu.be/') || url.includes('youtube.com/watch')) {
                        const videoId = url.includes('youtu.be/') 
                            ? url.split('youtu.be/')[1].split('?')[0]
                            : url.split('v=')[1].split('&')[0];
                        url = `https://www.youtube.com/embed/${videoId}`;
                    }
                    
                    const iframe = document.getElementById('pageViewer');
                    const loading = document.getElementById('loading');
                    
                    iframe.src = url;
                    
                    iframe.onload = () => {
                        loading.style.display = 'none';
                        iframe.style.display = 'block';
                    };
                    
                    setTimeout(() => {
                        loading.style.display = 'none';
                        iframe.style.display = 'block';
                    }, 3000);
                }
            } catch (error) {
                console.log('에러:', error);
            }
        }

        // 페이지 로드시 실행
        loadPage();
    </script>
</body>
</html>
