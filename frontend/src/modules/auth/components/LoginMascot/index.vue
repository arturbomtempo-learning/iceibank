<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, reactive, ref, useId, watch } from 'vue';

import mascotHead from '@/assets/mascot/mascot-head.webp';

const props = withDefaults(defineProps<{ covered?: boolean }>(), { covered: false });

const TURN_Y = 17;
const TURN_X = 12;
const SHIFT = 4.5;
const LIFT = 26;
const EASING = 0.12;

const cardGradientId = useId();
const chipGradientId = useId();

const root = ref<HTMLElement | null>(null);
const target = reactive({ x: 0, y: 0 });
const eased = reactive({ x: 0, y: 0 });

let frame = 0;

const headTransform = computed(
    () =>
        `translate3d(${(eased.x * SHIFT).toFixed(2)}%, ${(eased.y * SHIFT * 0.6).toFixed(2)}%, ${(
            (1 - Math.abs(eased.x)) *
            LIFT
        ).toFixed(1)}px)` +
        ` rotateY(${(eased.x * TURN_Y).toFixed(2)}deg)` +
        ` rotateX(${(-eased.y * TURN_X).toFixed(2)}deg)`
);

function clamp(value: number): number {
    return Math.min(1, Math.max(-1, value));
}

function handlePointer(event: PointerEvent): void {
    if (props.covered) return;

    const element = root.value;
    if (!element) return;

    const rect = element.getBoundingClientRect();
    if (rect.width === 0) return;

    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    const dx = event.clientX - centerX;
    const dy = event.clientY - centerY;

    target.x = clamp(dx / Math.max(dx >= 0 ? window.innerWidth - centerX : centerX, 1));
    target.y = clamp(dy / Math.max(dy >= 0 ? window.innerHeight - centerY : centerY, 1));
}

function tick(): void {
    eased.x += (target.x - eased.x) * EASING;
    eased.y += (target.y - eased.y) * EASING;
    frame = window.requestAnimationFrame(tick);
}

watch(
    () => props.covered,
    (covered) => {
        if (!covered) return;
        target.x = 0;
        target.y = 0.35;
    }
);

onMounted(() => {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    window.addEventListener('pointermove', handlePointer, { passive: true });
    frame = window.requestAnimationFrame(tick);
});

onBeforeUnmount(() => {
    window.removeEventListener('pointermove', handlePointer);
    window.cancelAnimationFrame(frame);
});
</script>

<template>
    <div ref="root" class="mascot" :class="{ 'mascot--covered': covered }" aria-hidden="true">
        <div class="mascot__window">
            <div class="mascot__float">
                <div class="mascot__scene">
                    <img
                        :src="mascotHead"
                        width="320"
                        height="279"
                        alt=""
                        class="mascot__head"
                        :style="{ transform: headTransform }"
                    />
                </div>
            </div>

            <svg class="mascot__card" viewBox="0 0 224 141" fill="none">
                <defs>
                    <linearGradient :id="cardGradientId" x1="18" y1="0" x2="206" y2="141">
                        <stop offset="0%" stop-color="#124a3e" />
                        <stop offset="52%" stop-color="#0a382f" />
                        <stop offset="100%" stop-color="#03251f" />
                    </linearGradient>
                    <linearGradient :id="chipGradientId" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stop-color="#d8dcdb" />
                        <stop offset="100%" stop-color="#a9afae" />
                    </linearGradient>
                </defs>

                <rect width="224" height="141" rx="15" :fill="`url(#${cardGradientId})`" />

                <g transform="translate(32 56)">
                    <rect width="40" height="29" rx="5.5" :fill="`url(#${chipGradientId})`" />
                    <g stroke="#0a382f" stroke-opacity="0.45" stroke-width="1.5" fill="none">
                        <path d="M0 10h12.5M0 19h12.5M27.5 10H40M27.5 19H40M20 0v6M20 23v6" />
                        <rect x="12.5" y="6" width="15" height="17" rx="4" />
                    </g>
                </g>

                <g
                    transform="translate(86 71)"
                    stroke="#cfe3db"
                    stroke-opacity="0.88"
                    stroke-width="2"
                    stroke-linecap="round"
                    fill="none"
                >
                    <path d="M0 -3a4.5 4.5 0 0 1 0 6" />
                    <path d="M4 -5.5a8 8 0 0 1 0 11" />
                    <path d="M8 -8a11.5 11.5 0 0 1 0 16" />
                    <path d="M12 -10.5a15 15 0 0 1 0 21" />
                </g>

                <g transform="translate(149 43)">
                    <g transform="rotate(-45 14 14)">
                        <rect x="-1" y="6" width="28" height="5.4" rx="2.7" fill="#ffffff" />
                        <rect x="4" y="13.5" width="21" height="5.4" rx="2.7" fill="#9fd9c9" />
                        <rect x="9" y="21" width="14" height="5.4" rx="2.7" fill="#3fb394" />
                    </g>
                </g>

                <g
                    font-family="'Plus Jakarta Sans', sans-serif"
                    font-size="16"
                    font-weight="800"
                    letter-spacing="-0.5"
                >
                    <text x="155" y="96" text-anchor="end" fill="#ffffff">ICEI</text>
                    <text x="155" y="96" text-anchor="start" fill="#3fb394">Bank</text>
                </g>
            </svg>
        </div>
    </div>
</template>

<style scoped>
.mascot {
    width: 100%;
    max-width: 17rem;
}

.mascot__window {
    position: relative;
    aspect-ratio: 1;
    overflow: hidden;
    border: 1px solid rgba(139, 180, 163, 0.32);
    border-radius: 30%;
    background:
        radial-gradient(120% 100% at 50% 0%, rgba(87, 227, 168, 0.12) 0%, transparent 62%),
        rgba(139, 180, 163, 0.07);
}

.mascot__float {
    position: absolute;
    inset: 0;
    display: grid;
    place-items: center;
    animation: mascot-float 7s ease-in-out infinite;
}

.mascot__scene {
    width: 84%;
    perspective: 480px;
}

.mascot__head {
    display: block;
    width: 100%;
    height: auto;
    transform-origin: 50% 62%;
    will-change: transform;
    filter: drop-shadow(0 16px 24px rgba(0, 0, 0, 0.32));
}

.mascot__card {
    position: absolute;
    left: 50%;
    top: 47%;
    width: 68%;
    transform: translate(-50%, 150%) rotate(10deg);
    opacity: 0;
    filter: drop-shadow(0 14px 26px rgba(0, 0, 0, 0.5));
    transition:
        transform 0.45s cubic-bezier(0.33, 1.3, 0.62, 1),
        opacity 0.18s ease;
}

.mascot--covered .mascot__card {
    transform: translate(-50%, -50%) rotate(-5deg);
    opacity: 1;
}

@keyframes mascot-float {
    0%,
    100% {
        transform: translateY(-1.5%);
    }
    50% {
        transform: translateY(1.5%);
    }
}

@media (prefers-reduced-motion: reduce) {
    .mascot__float {
        animation: none;
    }

    .mascot__card {
        transition: none;
    }
}
</style>
